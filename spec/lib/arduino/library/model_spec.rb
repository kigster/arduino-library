require 'spec_helper'
require 'json'

RSpec.describe Arduino::Library::Model do
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

        context '#version_to_i' do
          its(:version) { should eq '1.0.1' }
          its(:version_to_i) { should eq 1000001 }

          context 'different valid version' do
            before { hash['version'] = '3.145.10' }
            its(:version) { should eq '3.145.10' }
            its(:version_to_i) { should eq 3145010 }
          end

          context 'bad version' do
            before { hash['version'] = ugly_version }

            context 'different invalid version' do
              let(:ugly_version) { 'fdsadsf af jasdf ' }
              its(:version) { should eq ugly_version }
              its(:version_to_i) { should eq 0 }
            end

            context 'different real bad version' do
              let(:ugly_version) { Array.new }
              its(:version) { should eq ugly_version }
              its(:version_to_i) { should eq 0 }
            end

            context 'different real bad version' do
              let(:ugly_version) { nil }
              its(:version) { should eq ugly_version }
              its(:version_to_i) { should eq 0 }
            end
          end
        end
      end

      context 'json' do
        subject(:lib) { described_class.from(source) }
        context 'a file' do
          let(:source) { file }
          its(:name) { should eq 'AudioZero' }
        end

        context 'auto-detect json' do
          let(:source) { File.read(file) }
          its(:name) { should eq 'AudioZero' }
        end
      end

      context 'hash' do
        subject(:lib) { described_class.from({ name: 'AudioZero', version: '1.0.1'}, {}) }
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

    end
  end
end
