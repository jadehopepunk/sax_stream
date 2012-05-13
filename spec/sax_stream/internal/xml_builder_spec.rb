require 'spec_helper'
require 'sax_stream/internal/xml_builder'
require 'sax_stream/internal/element_content_mapping'

module SaxStream
  module Internal
    describe XmlBuilder do
      let(:builder)           { XmlBuilder.new }
      let(:object)            { double("mappable object", :node_name => 'FooBar', :attributes => {}, :mappings => []) }

      def base_attribute_mapping(name, value)
        ElementContentMapping.new(name, :to => "@#{name}").tap do |result|
          result.stub!(:value_from_object).with(object).and_return(value)
        end
      end

      def element_mapping(path, value)
        ElementContentMapping.new(path.split('/').first, :to => path).tap do |result|
          result.stub!(:value_from_object).with(object).and_return(value)
        end
      end

      context "building XML for object" do
        it "creates XML for the objects main node" do
          builder.build_xml_for(object).should == "<?xml version=\"1.0\"?>\n<FooBar/>\n"
        end

        it "includes attributes of the main node" do
          pending
          object.stub(:mappings => [base_attribute_mapping('a', 'b')])
          builder.build_xml_for(object).should == "<?xml version=\"1.0\"?>\n<FooBar a=\"b\"/>\n"
        end

        it "includes sub element of the main node" do
          object.stub(:mappings => [element_mapping('some', 'value')])
          builder.build_xml_for(object).should == "<?xml version=\"1.0\"?>\n<FooBar>\n  <some>value</some>\n</FooBar>\n"
        end

        it "includes sub sub element of the main node" do
          object.stub(:mappings => [element_mapping('red/fox', 'value')])
          builder.build_xml_for(object).should == "<?xml version=\"1.0\"?>\n<FooBar>\n  <red>\n    <fox>value</fox>\n  </red>\n</FooBar>\n"
        end

        it "includes multiple sub sub elements of the main node" do
          object.stub(:mappings => [element_mapping('red/fox', 'value'), element_mapping('red/goose', 'value2')])
          builder.build_xml_for(object).should == "<?xml version=\"1.0\"?>\n<FooBar>\n  <red>\n    <fox>value</fox>\n    <goose>value2</goose>\n  </red>\n</FooBar>\n"
        end

        # it "includes sub element attribute" do
        #   object.stub(:mappings => [element_mapping('red/@fox', 'value')])
        #   builder.build_xml_for(object).should == "<?xml version=\"1.0\"?>\n<FooBar>\n  <red fox=\"value\"/>\n</FooBar>\n"
        # end
        #
        # it "includes sub element attribute and value" do
        #   object.stub(:mappings => [element_mapping('red/@fox', 'value'), element_mapping('red', 'value2')])
        #   builder.build_xml_for(object).should == "<?xml version=\"1.0\"?>\n<FooBar>\n  <red fox=\"value\">value2</red>\n</FooBar>\n"
        # end

      end
    end
  end
end
