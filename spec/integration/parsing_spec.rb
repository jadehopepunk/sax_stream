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

    class Image
      include SaxStream::Mapper
      node 'img'

      map :id, :to => '@id'
    end

    class Business
      include SaxStream::Mapper

      node 'business'
      map :modified_at, :to => '@modTime', :as => ReaxmlDateTime
      map :office_name, :to => 'officeDetails/officeName'
      map :office_street_address, :to => 'officeDetails/addressStreet'
      relate :agent, :to => 'listingAgent', :as => Agent, :parent_collects => true
      relate :images, :to => 'images/img', :as => [Image], :parent_collects => true

      def office_street_address=(value)
        self['office_street_number'] = value.scan(/^[0-9\\\/\- ]*/).first.strip
      end
    end

    class Residential
      include SaxStream::Mapper

      node 'residential'
    end

    class PropertyList
      include SaxStream::Mapper

      node 'propertyList', :collect => false
      relate :properties, :as => [Business, Residential]
    end

    it "builds the appropriate object for each node" do
      parser = SaxStream::Parser.new(collector, [PropertyList])

      parser.parse_stream(open_fixture(:reaxml))
      collector.mapped_objects.map(&:class).map(&:name).should == [
        "Business", "Residential", "Residential", "Residential", "Residential", "Residential", "Residential",
        "Residential", "Residential", "Residential", "Residential", "Residential", "Residential", "Residential"
      ]
      business = collector.for_type(Business).first
      business['modified_at'].should == 'somedate: 2010-08-02-13:25'
      business['office_name'].should == 'Sydney Premier Real Estate'
      business['office_street_address'].should be_nil
      business['office_street_number'].should == '2/8'
      agent = business.relations['agent']
      agent.should_not be_nil
      agent.should be_a(Agent)
      agent['name'].should == 'Sonia Hume'

      business.relations['images'].map {|image| image['id']}.should ==
        %w(m a b c d e f g h i j k l n o p q r s t u v w x y z)
    end
  end

  context "with nested type using immediate content" do
    class UrlResource
      include SaxStream::Mapper
      node 'image'
      map :url, :to => ''
    end

    class Listing
      include SaxStream::Mapper
      node 'listing'
      relate :images, :to => 'images/image', :as => [UrlResource], :parent_collects => true
    end

    it "builds related nodes" do
      parser = SaxStream::Parser.new(collector, [Listing])

      parser.parse_stream(open_fixture(:image_children))
      listing = collector.mapped_objects.first
      listing.relations['images'].map {|image| image['url']}.should == [
        'http://example.com/image1.jpg',
        'http://example.com/image2.jpg'
      ]
    end
  end
end