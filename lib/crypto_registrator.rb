require 'acme-client'
require './config'

class CryptoRegistrator
  OWNER_EMAIL = 'mailto:alekseenkoss@gmail.com'

  # Account must provide domain and private_key
  attr_reader :account, :client, :challenge, :authrized

  def initialize(account)
    @account = account
  end

  def register
    @client = Acme::Client.new(
              private_key: account.private_key,
              endpoint: Config.settings['acme_endpoint'],
              connection_options: { request: { open_timeout: 20, timeout: 20 } }
            )

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
  end

  def obtain
    csr = Acme::Client::CertificateRequest.new(names: [account.domains])
    certificate = client.new_certificate(csr)
    save_certificate(certificate)    
    account.domain_cert = certificate.to_pem
    account.domain_private_key = certificate.request.private_key.to_pem
    $redis.set("#{account.domain}.crt", account.domain_cert)
    $redis.set("#{account.domain}.key", account.domain_private_key)
    account.save
  end

  def autorized?
    challenge.authorization.verify_status == 'valid'
  end

  def errors
    challenge.authorization.http01.errors
  end

  private

  def save_sertificate(certificate)
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
