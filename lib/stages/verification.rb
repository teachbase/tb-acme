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
      waiting_for_verification
      @resource.error(:authorization, "Challenge not verified") if pending?
      @resource
    end

    private

    def account
      @resource.account
    end

    def challenge
      @resource.challenge
    end

    def waiting_for_verification
      $logger.info(challenge.request_validation)
      $logger.info("[Challenge verification requested] challenge #{challenge}")

      counter = 0
      while pending?
        break if counter >= TIMEOUT

        sleep(ACME_DELAY_SEC)
        counter += 1
        challenge.reload
        $logger.info("[Challenge verification waiting] #{counter}/#{TIMEOUT}")
      end
      $logger.info(challenge)
    end

    def pending?
      challenge.status == 'pending'
    end

    def write_verification_token
      dir = File.join(public_path, File.dirname(challenge.filename))
      FileUtils.mkdir_p(dir) unless Dir.exists?(dir)

      File.write(File.join(public_path, challenge.filename), challenge.file_content)
    end

    def public_path
      @public_path ||= Config.settings['public_path']
    end
  end
end
