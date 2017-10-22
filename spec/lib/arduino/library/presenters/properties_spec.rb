require 'spec_helper'

module Arduino
  module Library
    RSpec.describe Presenters::Properties do

      let(:properties_file) { 'spec/fixtures/audio_zero.properties' }
      let(:actual) { File.read(properties_file) }
      let(:actual_lines) { actual.split("\n").sort }

      let(:json_file) { 'spec/fixtures/audio_zero.json' }
      let(:model) { Model.from_json_file(json_file) }

      context '#present' do
        context 'existing properties file' do
          it 'should match library name' do
            expect(actual).to match /name=AudioZero/
            expect(actual).to match /architectures=samd/
          end
        end

        subject(:presenter) { described_class.new(model) }

        context 'rendered version' do
          its(:present) { should match /name=AudioZero/ }
          its(:present) { should match /architectures=samd/ }
          its(:present) { should_not match /dot_a_linkage/ }
          it 'should have proper presented value' do
            expect(presenter.present).to eq presenter.presented
          end
        end
      end

      context '.from' do
        subject(:model) { described_class.from(properties_file) }
        context 'a local file' do
          its(:name) { should eq 'AudioZero' }

          context 'presenter on that model' do
            subject(:presenter) { described_class.new(model) }
            let(:presented_lines) { presenter.present.split(/\n/).sort }
            it 'should generate identical properties file to what we started with' do
              expect(presented_lines).to eq(actual_lines)
            end
          end
        end

        context 'from a remote URL', ci_only: true do
          let(:properties_file) { 'https://raw.githubusercontent.com/PaulStoffregen/DS1307RTC/master/library.properties' }
          its(:name) { should eq 'DS1307RTC' }
          its(:author) { should eq 'Michael Margolis' }
          its(:category) { should eq 'Timing' }
          its(:url) { should eq 'http://playground.arduino.cc/code/time' }
        end
      end
    end
  end
end
