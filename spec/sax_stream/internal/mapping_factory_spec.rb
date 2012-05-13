require 'spec_helper'
require 'sax_stream/internal/mapping_factory'

module SaxStream
  module Internal
    describe MappingFactory do
      context "when building mapping" do
        it "returns an attribute mapping if the last part of the :to option starts with an @" do
          MappingFactory.build_mapping('foobar', :to => '@foobar').should be_a(ElementAttributeMapping)
          MappingFactory.build_mapping('foobar', :to => 'foo/@bar').should be_a(ElementAttributeMapping)
        end

        it "returns an element mapping if the last part of the :to option doesnt start with an @" do
          MappingFactory.build_mapping('foobar', :to => 'foobar').should be_a(ElementContentMapping)
          MappingFactory.build_mapping('foobar', :to => 'foo/bar').should be_a(ElementContentMapping)
        end
      end
    end
  end
end