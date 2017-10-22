require 'spec_helper'

RSpec.describe Arduino::Library do
  it 'has a version number' do
    expect(Arduino::Library::VERSION).not_to be nil
  end

end
