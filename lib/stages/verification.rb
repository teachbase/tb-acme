# frozen_string_literal: true

module Stages
  class Verification
    TIMEOUT = 6
    ACME_DELAY_SEC = 5

    def initialize(resource)
      @resource = resource
    end

    def call
      return @resource if @resource.invalid?

      $logger.info("[Challenge verification starts] domain #{account.domain}")
      write_verification_token
      $logger.info("[Challenge verification token saved] domain #{account.domain}")
      waiting_for_verification
      $logger.info("[Challenge verified] domain #{account.domain}")
      @resource
    end

    private

    def challenge
      @resource.challenge
    end

    def waiting_for_verification
      challenge.request_validation
      $logger.info("[Challenge verification requested] challenge #{challenge}")

      counter = 0
      while challenge.status == 'pending'
        break if counter >= TIMEOUT

        sleep(ACME_DELAY_SEC)
        counter += 1
        challenge.reload
        $logger.info("[Challenge verification waiting] #{counter}/#{TIMEOUT}")
      end
    end

    def write_verification_token
      dir = File.join(public_path, File.dirname(challenge.filename))
      return if Dir.exists?(dir)

      FileUtils.mkdir_p(dir)
      File.write(File.join(public_path, challenge.filename), challenge.file_content)
    end

    def public_path
      @public_path ||= Config.settings['public_path']
    end
  end
end