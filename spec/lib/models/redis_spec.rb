# frozen_string_literal: true

require 'spec_helper'

module Models
  class Redis
    set_attributes :foo, :bar
  end
end

RSpec.describe Models::Redis do
  before { $redis.flushdb }

  describe ".save" do
    let(:object) { described_class.new(id: 10) }

    subject { object.save }

    it 'creates data in redis' do
      expect(subject).to be_truthy
      expect($redis.get("Models::Redis:#{object.id}")).to eq object.as_json.to_json
    end

    context 'without ID' do
      let(:object) { described_class.new }

      it "save with default ID" do
        expect(subject).to be_truthy
        expect($redis.get("Models::Redis:0")).to eq object.as_json.to_json
      end
    end

    context 'when redis raises error' do
      it 'returns true if error is about background save' do
        allow($redis).to receive(:save).and_raise(
          Redis::CommandError, 'ERR Background save already in progress'
        )
        expect(subject).to eq true
      end

      it 're-raises error if error is not about background save' do
        allow($redis).to receive(:save).and_raise(Redis::CommandError, 'Fail')
        expect { subject }.to raise_error(Redis::CommandError, 'Fail')
      end
    end
  end

  describe "#as_json" do
    let(:params) { { foo: 123, bar: 'abc' } }
    let(:object) { described_class.new(params) }

    subject { object.as_json }

    it 'responds hash format with object attributes' do
      expect(subject).to eq params
    end
  end

  describe '#add_error' do
    let(:params) { { foo: 123, bar: 'abc' } }
    let(:error) { 'some error message' }
    let(:object) { described_class.new(params) }

    subject { object.add_error(:foo, error) }

    it "pushes error message to @errors" do
      expect { subject }.to change { object.errors }.from({}).to({ :foo => error })
    end

    it 'marks object as invalid' do
      expect { subject }.to change { object.valid? }.from(true).to(false)
    end
  end
end
