require 'spec_helper'
require './lib/quota'

RSpec.describe Quota do
  before { $redis.flushdb }

  let(:quota) { described_class.new }

  describe "#get" do
    subject { quota.get }

    it 'returns nill by default' do
      expect(subject).to eq nil
    end

    context 'when has limit' do
      subject { quota.get }
      before { quota.reset }

      it 'returns limit' do
        expect(subject).to eq described_class::LIMIT
      end
    end
  end

  describe '#reset' do
    subject { quota.reset }

    it 'sets limit to default value' do
      expect { subject }.to change { quota.get }.from(nil).to(20)
    end
  end

  describe '#decr' do
    subject { quota.decr }

    it 'decrements quota value' do
      expect(subject).to eq(Quota::LIMIT - 1)
    end
  end

  describe '#available' do
    subject { quota.available? }

    context 'when limit is 0' do
      specify { expect(subject).to be_falsey }
    end

    context 'when limit is more than 0' do
      before { quota.reset }
      specify { expect(subject).to be_truthy }
    end
  end
end
