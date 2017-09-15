require 'acme-client'
require './lib/config'

class CryptoRegistrator
  OWNER_EMAIL = 'mailto:alekseenkoss@gmail.com'
  EXPIRATION_OFFSET = 83

  # Account must provide domain and private_key
  attr_reader :account, :client, :challenge, :authrized, :quota

  def initialize(account)
    @account = account
    @quota = Quota.new
    @client = Acme::Client.new(
              private_key: OpenSSL::PKey.read(account.private_key.to_s),
              endpoint: Config.settings['acme_endpoint'],
              connection_options: { request: { open_timeout: 20, timeout: 20 } }
            )
  end

  # TODO: make async registration
  def register
    return false unless valid?

    registration = client.register(contact: OWNER_EMAIL)
    registration.agree_terms
    authorization = client.authorize(domain: account.domain)
    account.auth_uri = authorization.uri
    @challenge = authorization.http01
    write_token(challenge.filename, challenge.file_content)
    challenge = client.fetch_authorization(account.auth_uri).http01
    challenge.request_verification
    sleep(5)
    challenge

    obtain
  end

  def obtain
    return false unless valid?
    
    $logger.info('-'*30 + "[OBTAIN START #{Time.now}] send request " + '-'*30)
    csr = Acme::Client::CertificateRequest.new(names: [account.domain])
    certificate = client.new_certificate(csr)
    $logger.info(certificate)
    $logger.info('-'*30 + "[OBTAIN END #{Time.now}]" + '-'*30)

    save_certificate(certificate)
    decrement_quota_counter
    set_cert_expiration
  end

  def autorized?
    challenge.authorization.verify_status == 'valid'
  end

  def errors
    challenge.authorization.http01.errors
  end

  def valid?
    quota.available?
  end

  private

  def set_cert_expiration
    expiration_date = (Date.today + EXPIRATION_OFFSET).strftime('%d%m%y')
    if cert_exp = CertExpiration.find(expiration_date)
      cert_exp.account_ids << account.id
      cert_exp.save
    else
      CertExpiration.new(id: expiration_date, account_ids: [account.id]).save
    end
  end

  def decrement_quota_counter
    quota.decr
  end

  def save_certificate(certificate)
    save_to_disk(certificate)
    account.domain_cert = certificate.to_pem
    account.domain_private_key = certificate.request.private_key.to_pem
    $redis.set("#{account.domain}.crt", account.domain_cert)
    $redis.set("#{account.domain}.key", account.domain_private_key)
    account.save
  end

  def save_to_disk(certificate)
    dir = Config.settings['private_path']
    create_dir(dir)

    File.write("#{dir}/#{account.domain}_privkey.pem", certificate.request.private_key.to_pem)
    File.write("#{dir}/#{account.domain}_cert.pem", certificate.to_pem)
    File.write("#{dir}/#{account.domain}_chain.pem", certificate.chain_to_pem)
    File.write("#{dir}/#{account.domain}_fullchain.pem", certificate.fullchain_to_pem)
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
end
