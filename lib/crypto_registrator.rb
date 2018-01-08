require 'acme-client'
require './lib/config'

class CryptoRegistrator
  OWNER_EMAIL = Config.settings['owner_email']
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
    unless valid?
      return false
      log("INVALID", "Quota overhead")
    end

    begin
      log('REGISTRATION START', "#{account.id} - #{account.domain}")
      registration = client.register(contact: OWNER_EMAIL)
      registration.agree_terms
      authorization = client.authorize(domain: account.domain)
      account.auth_uri = authorization.uri
      @challenge = authorization.http01
      write_token(challenge.filename, challenge.file_content)
      challenge = client.fetch_authorization(account.auth_uri).http01
      challenge.request_verification
    rescue => e
      if /Registration key is already in use/ === e.message
        log('REGISTRATION FAILED', e.message)
        return obtain
      else
        raise e
      end
    end

    # If no any exceptions, then
    # wait five seconds synchronously and obtain
    sleep(10)
    if authorized?
      log('REGISTRATION END')
      obtain
    else
      log('REGISTRATION FAILED', authorization.http01.error)
    end
  end

  def obtain
    return false unless valid?
    log('OBTAIN START')
    csr = Acme::Client::CertificateRequest.new(names: [account.domain])
    certificate = client.new_certificate(csr)
    log('CERTIFICATE', certificate)
    log('OBTAIN END')

    save_certificate(certificate)
    decrement_quota_counter
    set_cert_expiration
  end

  def authorized?
    challenge.authorization.verify_status == 'valid'
  end

  def valid?
    quota.available?
  end

  private

  def set_cert_expiration
    expiration_date = (Date.today + EXPIRATION_OFFSET).strftime('%d%m%y')
    if cert_exp = CertExpiration.find(expiration_date)
      cert_exp.append(account.id)
    else
      CertExpiration.new(id: expiration_date, account_ids: [account.id]).save
    end
  end

  def decrement_quota_counter
    quota.decr
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

  def log(event_name, *params)
    $logger.info("[#{event_name}, #{Time.now}] #{params.join(', ')}")
  end
end
