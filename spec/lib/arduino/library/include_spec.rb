require 'spec_helper'

RSpec.describe Arduino::Library do
  PUBLIC_METHODS = %i(find_library search db_from db_default library_from)

  class Foo
    include Arduino::Library
  end

  let(:foo) { Foo.new }

  PUBLIC_METHODS.each do |method|
    it "##{method}" do
      expect(foo.respond_to?(method)).to be true
    end
  end
end
