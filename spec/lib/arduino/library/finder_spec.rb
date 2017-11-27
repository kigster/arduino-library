require 'spec_helper'

module Arduino
  module Library
    RSpec.describe Finder, local_index: true do

      LibrarySpec = Struct.new(:name, :version, :expected_version)

      EXPECTATIONS = [
        LibrarySpec.new('AudioZero', nil, '1.1.1'),
        LibrarySpec.new('AudioZero', '1.0.1', '1.0.1'),
        LibrarySpec.new('Esplora', '1.0.2', '1.0.2'),
        LibrarySpec.new('Esplora', nil, '1.0.4'),
        LibrarySpec.new('Alksjflsdfl', nil, nil)
      ]

      context '#find' do
        let(:partial_model) { Model.from_hash(query) }
        subject(:resolved) { Finder.find(partial_model) }

        EXPECTATIONS.each do |lib_spec|
          context "#{lib_spec}" do
            let(:query) { { name: lib_spec.name, version: lib_spec.version } }
            if lib_spec.expected_version.nil?
              its(:nil?) { should be true }
            else
              its(:version) { should eq lib_spec.expected_version }
              its(:name) { should eq lib_spec.name }
              its(:url) { should_not be_nil }
            end
          end
        end
      end
    end
  end
end

