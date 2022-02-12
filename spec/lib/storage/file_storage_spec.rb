# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Storage::FileStorage do
  let(:path) { '/tmp/tb-acme' }
  let(:filename) { "text.example.com" }
  let(:content) { SecureRandom.hex(16) }

  subject { described_class.new(path) }

  describe 'save' do
    context 'when folder is missing' do
      before { FileUtils.rm_r(path, force: true, secure: true) }

      it 'creates the folder' do
        subject.save(filename, content)
        expect(Dir.exists?(path)).to be_truthy
      end
    end
    
    it 'creates file with content' do
      subject.save(filename, content)
      expect(File.read("#{path}/#{filename}")).to eq(content)
    end
  end
end
