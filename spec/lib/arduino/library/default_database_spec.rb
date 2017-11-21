require 'spec_helper'
require 'json'

RSpec.describe Arduino::Library::DefaultDatabase do
  context '#initialize' do
    before do
      described_class.library_index_path = '/tmp/library_index.json.gz'
      described_class.instance.reload!
    end

    context 'from a default url' do
      let(:db) { described_class.instance }
      its(:size) { should > 3600 }
    end
  end
end

