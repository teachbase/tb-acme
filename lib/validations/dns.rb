# frozen_string_literal: true

require 'resolv'
require './lib/config'

module Validations
  class DNS  
    attr_reader :domain, :resolver, :errors

    def initialize(domain)
      @domain = domain
      @errors = []
      @resolver = Resolv::DNS.new
    end

    def valid?
      validate!
      errors.empty?
    end

    def validate!
      validate_front_ip
      check_ip_v4
      check_ip_v6
    ensure
      resolver.close
    end

    private

    def frontend_domain
      Config.settings['front_domain']
    end

    def frontend_ip
      @front_ip ||= resolver.getaddress(frontend_domain)
    rescue Resolv::ResolvError => e
      error("Resolve DNS error for #{frontend_domain}")
    end

    def validate_front_ip
      return if frontend_ip.is_a?(Resolv::IPv4)
      error("Frontend IPv4 Invalid")
    end

    def equal_address?(addr)
      addr == frontend_ip
    end

    def check_ip_v4
      addr = resolver.getaddress(domain)
      return if addr.is_a?(Resolv::IPv4)
      error("Domain #{domain} has invalid IPv4 address")
    end

    def check_ip_v6
      resolver.each_address(domain) do |addr|
        if addr.is_a?(Resolv::IPv6)
          error("Domain #{domain} must not have IPv6, but has #{addr}")
          return
        end
      end
    end

    def error(msg)
      @errors << msg
    end
  end
end
