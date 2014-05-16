require 'integration_spec_helper'
require 'sax_stream/mapper'
require 'sax_stream/parser'
require 'sax_stream/collectors/naive_collector'

describe "sax stream parser" do
  let(:collector) { SaxStream::Collectors::NaiveCollector.new }

  context "with aa empty file" do
    class Properties
      include SaxStream::Mapper

      node 'properties', :collect => false
    end

    it "parses no objects but raises no error" do
      parser = SaxStream::Parser.new(collector, [Properties])

      parser.parse_stream(open_fixture(:empty_file))

      collector.mapped_objects.should == []
    end
  end
end