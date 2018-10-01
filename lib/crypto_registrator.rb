# frozen_string_literal: true

require 'acme-client'
require './lib/config'

class CryptoRegistrator
  OWNER_EMAIL = Config.settings['owner_email']
  EXPIRATION_OFFSET = 60
  ACME_DELAY_SEC = 5

  # Account must provide domain and private_key
  attr_reader :account, :client, :challenge, :order, :certificate

  def initialize(account)
    @account = account
    @client = Acme::Client.new(
                kid: account.kid,
                private_key: OpenSSL::PKey.read(account.private_key.to_s),
                directory: Config.settings['acme_endpoint'],
                connection_options: { request: { open_timeout: 20, timeout: 20 } }
              )
  end

  def perform
    register
    order_certificate
    issue
  end
  
  private

  def register
    log(:info, 'ACCOUNT REGISTRATION', "owner: #{OWNER_EMAIL}")
    acme_account = client.new_account(contact: OWNER_EMAIL, terms_of_service_agreed: true)
    account.kid = acme_account.kid
    account
  end

  def order_certificate
    log(:info, 'ORDER CERTIFICATE', "domain: #{account.domain}")
    
    @order = client.new_order(identifiers: [account.domain])
    authorization = order.authorizations.first
    account.auth_uri = authorization.url
    @challenge = authorization.http
    write_token(challenge.filename, challenge.file_content)
    challenge.request_validation

    count = 0
    while challenge.status == 'pending'
      break if count >= 6
      sleep(ACME_DELAY_SEC)
      count += 1
      challenge.reload
    end

    challenge

  rescue => e
    if /Registration key is already in use/ === e.message
      log(:error, 'REGISTRATION FAILED', e.message)
      return issue
    else
      raise e
    end
  end

  def issue
    return false unless authorized?

    log(:info, 'Issue certificate')
    
    @certificate = waiting_ordered_certificate
    
    log(:info, '[OK] Certificate issued successful', certificate)
    
    save_certificate(certificate)
    set_cert_expiration
  end

  def authorized?
    challenge.status == 'valid'
  end

  def waiting_ordered_certificate
     csr = Acme::Client::CertificateRequest.new(
      private_key: OpenSSL::PKey::RSA.new(4096),
      subject: { common_name: account.domain }
    )

    order.finalize(csr: csr)
    sleep(1) while order.status == 'processing'
    order.certificate
  end

  def set_cert_expiration
    expiration_date = (Date.today + EXPIRATION_OFFSET).strftime('%d%m%y')
    if cert_exp = CertExpiration.find(expiration_date)
      cert_exp.append(account.id)
    else
      CertExpiration.new(id: expiration_date, account_ids: [account.id]).save
    end
  end

  def save_certificate(certificate)
    save_to_disk(certificate)

    # Set fullchain certificate to account settings
    account.domain_cert = certificate.fullchain_to_pem
    account.domain_private_key = certificate.request.private_key.to_pem

    $redis.set("#{account.domain}.crt", account.domain_cert)
    $redis.set("#{account.domain}.key", account.domain_private_key)
    account.save
  end

  def save_to_disk(certificate)
    dir = Config.settings['private_path']
    create_dir(dir)

    File.write("#{dir}/#{account.domain}.key", certificate.request.private_key.to_pem)
    File.write("#{dir}/#{account.domain}.crt", certificate.fullchain_to_pem)
  end

  def write_token(filename, file_content)
    dir = File.join(Config.settings['public_path'], File.dirname(filename))
    create_dir(dir)

    File.write(File.join(Config.settings['public_path'], filename), file_content)
  end

  def create_dir(dir)
    return if Dir.exists?(dir)
    FileUtils.mkdir_p(dir)
  end

  def log(level, event_name, *params)
    $logger.public_send(level, "[#{event_name}, #{Time.now}] #{params.join(', ')}")
  end
end
