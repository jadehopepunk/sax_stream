require 'integration_spec_helper'
require 'sax_stream/mapper'
require 'sax_stream/parser'
require 'sax_stream/naive_collector'

describe "sax stream parser" do
  let(:collector) { SaxStream::NaiveCollector.new }

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

  context "with a complex list of different node types" do
    class Business
      include SaxStream::Mapper

      node 'business'
    end

    class Residential
      include SaxStream::Mapper

      node 'residential'
    end

    class PropertyList
      include SaxStream::Mapper

      node 'propertyList'
      children :properties, :as => [Business, Residential]
    end

    it "builds the appropriate object for each node" do
      parser = SaxStream::Parser.new(collector => [PropertyList])

      parser.parse_stream(open_fixture(:reaxml))
      raise collector.mapped_objects.inspect
    end
  end
end