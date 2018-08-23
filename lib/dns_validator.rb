# frozen_string_literal: true

require 'resolv'

class DnsValidator
  TB_DOMAIN = Config.settings['front_domain']
  
  AddressNotIPv4 = Class.new(StandardError) 
  
  attr_reader :domain, :resolver

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
    validate_tb_ip
    check_ip_addr
  ensure
    resolver.close
  end

  private

  def frontend_ip
    @front_ip ||= resolver.getaddress(TB_DOMAIN)
  end

  def validate_front_ip
    return if frontend_ip.is_a?(Resolv::IPv4)
    raise AddressNotIPv4, 'Frontend IPv4 Invalid'
  end

  def equal_address?(ip)
    ip == teachbase_ip
  end

  def check_ip_addr
    resolver.each_address(domain) do |addr|
      if addr.is_a?(Resolv::IPv6)
        error("Domain #{domain} must not have IPv6, but has #{addr}")
        return
      end

      return addr if equal_address?(addr)
      
      error("Domain #{domain} with #{ip} is mismatched with Frontend IPv4 address")
    end
  end

  def error(msg)
    @errors << msg
  end
end
