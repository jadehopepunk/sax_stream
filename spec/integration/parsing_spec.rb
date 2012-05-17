require 'integration_spec_helper'
require 'sax_stream/mapper'
require 'sax_stream/parser'
require 'sax_stream/collectors/naive_collector'

describe "sax stream parser" do
  let(:collector) { SaxStream::Collectors::NaiveCollector.new }

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

    it "builds the xml from a mapped object" do
      product = Product.new
      product.attributes = {'id' => '123', 'status' => 'new', 'name_confirmed' => 'yes', 'name' => 'iPhone 5G'}
      product.to_xml.strip.should == read_fixture(:simple_product)
    end
  end

  context "with a complex list of different node types" do
    class ReaxmlDateTime
      def self.parse(string)
        "somedate: #{string}"
      end

      def self.format(value)
        value.sub(/^somedate\: /, '')
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

    class PropertyBase
      include SaxStream::Mapper
      map :modified_at, :to => '@modTime', :as => ReaxmlDateTime
    end

    class Business < PropertyBase
      node 'business'
      map :office_name, :to => 'officeDetails/officeName', :cdata => true
      map :office_street_address, :to => 'officeDetails/addressStreet', :cdata => true
      relate :agent, :to => 'listingAgent', :as => Agent, :parent_collects => true
      relate :images, :to => 'images/img', :as => [Image], :parent_collects => true

      def office_street_address=(value)
        self['office_street_number'] = value.scan(/^[0-9\\\/\- ]*/).first.strip
      end

      def office_street_address
        self['office_street_number']
      end
    end

    class Residential < PropertyBase
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
      business.attributes.class.should == Hash
      agent = business.relations['agent']
      agent.should_not be_nil
      agent.should be_a(Agent)
      agent['name'].should == 'Sonia Hume'

      business.relations['images'].map {|image| image['id']}.should ==
        %w(m a b c d e f g h i j k l n o p q r s t u v w x y z)
    end

    it "builds the xml from one mapped object" do
      parser = SaxStream::Parser.new(collector, [PropertyList])
      parser.parse_stream(open_fixture(:reaxml))
      business = collector.mapped_objects.first
      business.to_xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<business modTime=\"2010-08-02-13:25\">\n  <officeDetails>\n    <officeName><![CDATA[Sydney Premier Real Estate]]></officeName>\n    <addressStreet><![CDATA[2/8]]></addressStreet>\n  </officeDetails>\n  <listingAgent>\n    <name>Sonia Hume</name>\n  </listingAgent>\n  <images>\n    <img id=\"m\"/>\n    <img id=\"a\"/>\n    <img id=\"b\"/>\n    <img id=\"c\"/>\n    <img id=\"d\"/>\n    <img id=\"e\"/>\n    <img id=\"f\"/>\n    <img id=\"g\"/>\n    <img id=\"h\"/>\n    <img id=\"i\"/>\n    <img id=\"j\"/>\n    <img id=\"k\"/>\n    <img id=\"l\"/>\n    <img id=\"n\"/>\n    <img id=\"o\"/>\n    <img id=\"p\"/>\n    <img id=\"q\"/>\n    <img id=\"r\"/>\n    <img id=\"s\"/>\n    <img id=\"t\"/>\n    <img id=\"u\"/>\n    <img id=\"v\"/>\n    <img id=\"w\"/>\n    <img id=\"x\"/>\n    <img id=\"y\"/>\n    <img id=\"z\"/>\n  </images>\n</business>\n"
    end

    it "builds the XML for a property list" do
      parser = SaxStream::Parser.new(collector, [PropertyList])
      parser.parse_stream(open_fixture(:reaxml))

      list = PropertyList.new
      list.relations['properties'] = collector.mapped_objects
      list.to_xml.should == open_fixture(:reaxml_output).read
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

  context "with node containing node of same name" do
    class Xml2uImage
      include SaxStream::Mapper

      node 'image'

      map :title, :to => 'alttext'
      map :number, :to => '@number'
      map :url, :to => 'image'
    end

    class Xml2uProperty
      include SaxStream::Mapper

      node 'property'
      relate :images, :to => "images/image", :as => [Xml2uImage], :parent_collects => true
    end

    class Xml2uDocument
      include SaxStream::Mapper

      node 'document', :collect => false
      relate :properties, :to => 'Clients/Client/properties/property', :as => [Xml2uProperty]
    end

    it "builds related node ok" do
      parser = SaxStream::Parser.new(collector, [Xml2uDocument])
      parser.parse_stream(open_fixture(:xml2u))
      property = collector.mapped_objects.first
      property.relations['images'].first['url'].should == 'http://www.euro-immo.com/photo/euro11496p107602.jpg'
    end
  end
end