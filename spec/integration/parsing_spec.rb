require 'integration_spec_helper'
require 'sax_stream/mapper'
require 'sax_stream/parser'
require 'sax_stream/naive_collector'

describe "sax stream parser" do
  context "with a single node file" do
    class Product
      include SaxStream::Mapper

      node 'product'
      map :id,             :to => '@id'
      map :status,         :to => '@status'
      map :name_confirmed, :to => 'name/@confirmed'
      map :name,           :to => 'name'
    end

    it "builds the mapped object for the node and passes it to the collector" do
      collector = SaxStream::NaiveCollector.new
      parser = SaxStream::Parser.new(collector => [Product])

      parser.parse_stream(open_fixture(:simple_product))

      collector.mapped_objects.length.should == 1
      product = collector.mapped_objects.first
      product.should be_a(Product)
      product['id'].should == '123'
      product['status'].should == 'new'
      product['name_confirmed'].should == 'yes'
      product['name'].should == 'iPhone 5G'
    end
  end
end