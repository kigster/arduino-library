require 'spec_helper'
require 'json'

RSpec.describe Arduino::Library::Database do
  context '#initialize' do
    let(:schema) { Arduino::Library::Types.schema }
    let(:file) { 'spec/fixtures/library_index.json' }
    let(:gzip_file) { 'spec/fixtures/library_index.json.gz' }
    let(:url) { '' }
    let(:libs) { json['libraries'] }
    let(:db) { described_class.new(file_or_url) }

    subject(:db_list) { db.to_a }

    context 'from a file' do
      let(:file_or_url) { file }
      its(:size) { should eq 16 }
    end

    context 'using .from' do
      let(:db) { described_class.from(file) }
      its(:size) { should eq 16 }
    end

    context 'from a gzipped local file' do
      let(:file_or_url) { gzip_file }
      its(:size) { should eq 16 }

      context '#search' do
        let(:local_audio_zero) { Arduino::Library::Model.from_json_file('spec/fixtures/audio_zero.json') }

        let(:audio_zero) { db.search(name: 'AudioZero', version: '1.0.1') }
        it 'should find our AudioZero library' do
          expect(audio_zero.first.to_hash).to eql(local_audio_zero.to_hash)
        end
        it 'should yield if block given' do
          db.search(name: 'AudioZero', version: '1.0.1') do |library|
            expect(library.version).to eq('1.0.1')
            expect(library.name).to eq('AudioZero')
          end
        end

        context 'various finder types' do
          let(:name) { 'AudioZero' }
          let(:version) { '1.0.1' }
          subject(:result) { db.search(name: name, version: version_argument).first }

          context 'String' do
            let(:version_argument) { '1.0.1' }
            its(:version) { should eq version }
            its(:name) { should eq name }
          end

          context 'Regexp' do
            let(:version_argument) { /\d\.\d\.1/ }
            its(:version) { should eq version }
            its(:name) { should eq name }
          end

          context 'Proc' do
            let(:version_argument) { ->(value) { value == version } }
            its(:version) { should eq version }
            its(:name) { should eq name }
          end

          context 'Array' do
            let(:architectures) { %w(avr) }
            subject(:results) { db.search(architectures: architectures) }
            it { is_expected.to_not be_nil }
            its(:size) { should eq 7 }
            context 'resulting array' do
              subject(:returned_architectures) { results.map(&:architectures).flatten.uniq }
              its(:first) { should eq 'avr' }
              its(:last) { should eq '*' }
              its(:size) { should eq 2 }
            end
          end
        end
      end

      context 'from a default url', ci_only: true do
        let(:db) { described_class.default }
        its(:size) { should > 3600 }
      end

    end

  end
end
