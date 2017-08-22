require 'acme-client'

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
              endpoint: $acme_endpoint,
              connection_options: { request: { open_timeout: 20, timeout: 20 } }
            )

    registration = client.register(contact: OWNER_EMAIL)
    registration.agree_terms
    authorization = client.authorize(domain: account.domain)
    account.auth_uri = authorization.uri
    @challenge = authorization.http01

    FileUtils.mkdir_p(File.join($public_path, File.dirname(challenge.filename)))
    File.write(File.join($public_path, challenge.filename), challenge.file_content)

    challenge = client.fetch_authorization(account.auth_uri).http01
    challenge.request_verification
  end

  def autorized?
    challenge.authorization.verify_status == 'valid'
  end

  def errors
    challenge.authorization.http01.errors
  end
end
