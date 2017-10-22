require 'spec_helper'

RSpec.describe Arduino::Library do
  include Arduino::Library

  it 'has a version number' do
    expect(Arduino::Library::VERSION).not_to be nil
  end

  context '#library_from' do
    subject(:model) { library_from(file_or_url) }

    context 'json' do
      context 'gzipped' do
        let(:file_or_url) { 'spec/fixtures/audio_zero.json.gz' }
        its(:name) { should eq 'AudioZero' }
        its(:checksum) { should_not be_nil }
      end

      context 'plain' do
        let(:file_or_url) { 'spec/fixtures/audio_zero.json' }
        its(:name) { should eq 'AudioZero' }
        its(:checksum) { should_not be_nil }
      end
    end

    context 'properties' do
      context 'gzipped' do
        let(:file_or_url) { 'spec/fixtures/audio_zero.properties.gz' }
        its(:name) { should eq 'AudioZero' }
        its(:checksum) { should be_nil }
      end

      context 'plain' do
        let(:file_or_url) { 'spec/fixtures/audio_zero.properties' }
        its(:name) { should eq 'AudioZero' }
        its(:checksum) { should be_nil }
      end
    end
  end

  context '#db_from' do
    subject(:db) { db_from('spec/fixtures/library_index.json.gz') }
    its(:size) { should eq(16)}

    context '#find' do
      subject(:results) { find(db, name: 'AudioZero', version: '1.0.1').first }
      its(:name) { should eq 'AudioZero'}
      its(:version) { should eq '1.0.1'}
    end
  end
end
