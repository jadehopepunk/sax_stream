require 'integration_spec_helper'
require 'sax_stream/mapper'
require 'sax_stream/parser'
require 'sax_stream/naive_collector'

describe "sax stream parser" do
  context "with a single node file" do
    class ProductMapper
      include SaxStream::Mapper
    end

    it "builds the mapped object for the node and passes it to the collector" do
      collector = SaxStream::NaiveCollector.new
      parser = SaxStream::Parser.new(collector => [ProductMapper])

      parser.parse_stream(open_fixture(:simple_product))

      collector.mapped_objects.length.should == 1
      product = collector.mapped_objects.first
      product.should be_a?(ProductMapper)
      product['id'].should == '123'
      product['status'].should == 'new'
    end
  end
end