require 'spec_helper'
require 'json'

RSpec.describe Arduino::Library::Properties do
  context '#initialize' do
    let(:schema) { Arduino::Library::Types.schema }

    let(:file) { 'spec/fixtures/audio_zero.json' }
    let(:json) { JSON.load(File.read(file)) }
    let(:hash) { json }
    let(:converted) { schema[hash] }

    subject(:props) { described_class.new(**converted) }

    context 'loading from a single-library JSON' do
      it 'should load the hash' do
        expect(hash['name']).to eq 'AudioZero'
      end

      context 'converting from a hash' do
        it 'should be fully converted' do
          expect(converted[:name]).to eq 'AudioZero'
        end
        its(:name) { should eq 'AudioZero' }
        its(:version) { should eq '1.0.1' }
        its(:author) { should eq 'Arduino' }
        its(:sentence) { should eq 'Allows playing audio files from an SD card. For Arduino Zero only.' }
        its(:paragraph) { should eq "With this library you can use the Arduino Zero DAC outputs to play audio files.\u003cbr /\u003eThe audio files must be in the raw .wav format." }
        its(:architectures) { should eq %w(samd) }
        its(:types) { should eq %w(Arduino) }
        its(:url) { should eq 'http://downloads.arduino.cc/libraries/github.com/arduino-libraries/AudioZero-1.0.1.zip' }
        its(:checksum) { should eq 'SHA-256:c938f00aceec2f91465d1486b4cd2d3e1299cdc271eb743d2dedcd8c2dd355a8' }
        its(:size) { should eq 4925 }
        its(:archiveFileName) { should eq 'AudioZero-1.0.1.zip' }
      end

      context '.from_json' do
        subject(:props) { described_class.from_json_file(file) }
        its(:name) { should eq 'AudioZero' }
      end
    end

    context 'reading from the index multi-library JSON' do
      let(:file) { 'spec/fixtures/library_index.json' }
      let(:libs) { json['libraries'] }

      it 'should load the hash' do
        expect(libs.size).to eq(16)
      end

      16.times do |index|
        let(:hash) { json['libraries'][index] }
        it 'should properly initialize Properties#name' do
          expect(props.name).to eq(hash['name'])
        end
        it 'should properly initialize Properties#url' do
          expect(props.url).to eq(hash['url'])
        end
      end

      context '.database' do
        subject(:database) { described_class.database(file) }
        its(:size) { should eq 16 }
      end
    end
  end
end
