# frozen_string_literal: true

module Stages
  class Verification
    TIMEOUT = 6.freeze
    ACME_DELAY_SEC = 5.freeze
    
    def initialize(resource)
      @resource = resource
    end

    def call
      write_verification_token
      waiting_for_verification
    end

    private

    def challenge
      @resource.challenge
    end

    def waiting_for_verification
      challenge.request_validation

      counter = 0
      while challenge.status == 'pending'
        break if counter >= TIMEOUT
        sleep(ACME_DELAY_SEC)
        counter += 1
        challenge.reload
      end

      challenge
    end

    def write_verification_token
      dir = File.join(public_path, File.dirname(@challenge.filename))
      return if Dir.exists?(dir)
  
      FileUtils.mkdir_p(dir)
      File.write(File.join(public_path, @challenge.filename), @challenge.file_content)
    end

    def public_path
      @public_path ||= Config.settings['public_path']
    end
  end
end
