# frozen_string_literal: true

require 'spec_helper'
require './lib/models/cert_expiration'

RSpec.describe Models::CertExpiration do
  before { $redis.flushdb }

  let(:date) { Date.today.strftime('%d%m%y') }
  let(:cert_exp) { described_class.new(id: date, account_ids: [1,2,3]).save }

  describe '#today' do
    before { cert_exp }
    subject { described_class.today }

    it 'returns expiration for today' do
      expect(subject.as_json).to eq({ id: date, account_ids: [1,2,3] })
    end
  end
end
