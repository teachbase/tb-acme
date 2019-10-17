# frozen_string_literal: true

require 'spec_helper'

describe Validations::DNS do
  before { $redis.flushdb }

  describe '#valid?' do
    let!(:domain) { 'ssl.teachbase.ru' }

    subject { described_class.new(domain) }

    it 'respond true' do
      expect(subject.valid?).to be_truthy
    end

    context 'when frontend domain is invalid' do
      it 'respond false' do
        Config.settings['front_domain'] = 'ja9g8dsjpjapodkf9ug893p90.com'
        expect(subject.valid?).to be_falsey
      end
    end
  end
end
