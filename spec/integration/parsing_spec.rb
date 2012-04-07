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
      parser = SaxStream::Parser.new(collector, [Product])

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
    class ReaxmlDateTime
      def self.parse(string)
        "somedate: #{string}"
      end
    end

    class Agent
      include SaxStream::Mapper
      node 'listingAgent'

      map :name, :to => 'name'
    end

    class Business
      include SaxStream::Mapper

      node 'business'
      map :modified_at, :to => '@modTime', :as => ReaxmlDateTime
      map :office_name, :to => 'officeDetails/officeName'
      relate :agent, :to => 'listingAgent', :as => Agent, :collect => true
    end

    class Residential
      include SaxStream::Mapper

      node 'residential'
    end

    class PropertyList
      include SaxStream::Mapper

      node 'propertyList'
      relate :properties, :as => [Business, Residential]
    end

    it "builds the appropriate object for each node" do
      parser = SaxStream::Parser.new(collector, [PropertyList])

      parser.parse_stream(open_fixture(:reaxml))
      collector.mapped_objects.map(&:class).map(&:name).should == [
        "Agent",
        "Business", "Residential", "Residential", "Residential", "Residential", "Residential", "Residential",
        "Residential", "Residential", "Residential", "Residential", "Residential", "Residential", "Residential",
        "PropertyList"
      ]
      business = collector.for_type(Business).first
      business['modified_at'].should == 'somedate: 2010-08-02-13:25'
      business['office_name'].should == 'Sydney Premier Real Estate'
      # agent = business['agent']
      # agent.should be_nil
      # agent.should be_a(Agent)
      # agent.name.should == 'Sonia Hume'
    end
  end
end