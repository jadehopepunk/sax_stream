require 'spec_helper'
require 'sax_stream/internal/xml_builder'
require 'sax_stream/internal/mappings/element_content'
require 'sax_stream/internal/mappings/element_attribute'

module SaxStream
  module Internal
    describe XmlBuilder do
      let(:builder)           { XmlBuilder.new }
      let(:object)            { double("mappable object", :node_name => 'FooBar', :attributes => {}, :mappings => []) }

      def attribute_mapping(path, value)
        Mappings::ElementAttribute.new(path.gsub(/^@/, ''), :to => path).tap do |result|
          result.stub!(:string_value_from_object).with(object).and_return(value)
        end
      end

      def element_mapping(path, value, options = {})
        options[:name] ||= path.split('/').first
        Mappings::ElementContent.new(options[:name], :to => path).tap do |result|
          result.stub!(:string_value_from_object).with(object).and_return(value)
        end
      end

      context "building XML for object" do
        it "creates XML for the objects main node" do
          builder.build_xml_for(object).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<FooBar/>\n"
        end

        it "includes attributes of the main node" do
          object.stub(:mappings => [attribute_mapping('@a', 'b')])
          builder.build_xml_for(object).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<FooBar a=\"b\"/>\n"
        end

        it "includes content for the main node" do
          object.stub(:mappings => [element_mapping('', 'value', :name => 'url')])
          builder.build_xml_for(object).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<FooBar>value</FooBar>\n"
        end

        it "includes sub element of the main node" do
          object.stub(:mappings => [element_mapping('some', 'value')])
          builder.build_xml_for(object).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<FooBar>\n  <some>value</some>\n</FooBar>\n"
        end

        it "includes sub sub element of the main node" do
          object.stub(:mappings => [element_mapping('red/fox', 'value')])
          builder.build_xml_for(object).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<FooBar>\n  <red>\n    <fox>value</fox>\n  </red>\n</FooBar>\n"
        end

        it "includes multiple sub sub elements of the main node" do
          object.stub(:mappings => [element_mapping('red/fox', 'value'), element_mapping('red/goose', 'value2')])
          builder.build_xml_for(object).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<FooBar>\n  <red>\n    <fox>value</fox>\n    <goose>value2</goose>\n  </red>\n</FooBar>\n"
        end

        it "includes sub element attribute" do
          object.stub(:mappings => [attribute_mapping('red/@fox', 'value')])
          builder.build_xml_for(object).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<FooBar>\n  <red fox=\"value\"/>\n</FooBar>\n"
        end

        it "includes sub element attribute and value" do
          object.stub(:mappings => [attribute_mapping('red/@fox', 'value'), element_mapping('red', 'value2')])
          builder.build_xml_for(object).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<FooBar>\n  <red fox=\"value\">value2</red>\n</FooBar>\n"
        end
      end
    end
  end
end
