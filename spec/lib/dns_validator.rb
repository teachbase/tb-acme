# frozen_string_literal: true

require 'spec_helper'
require './lib/dns_validator'

describe DnsValidator do
  before { $redis.flushdb }

  before { Config.settings['front_domain'] = 'go.teachbase.ru' }

  describe '#valid?' do
    let!(:domain) { 'ssl.teachbase.ru' }

    subject { described_class.new(domain) }

    it 'respond true' do
      expect(subject.valid?).to be_truthy
    end
  end
end
