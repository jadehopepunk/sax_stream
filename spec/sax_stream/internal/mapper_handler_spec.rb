require 'spec_helper'
require 'sax_stream/internal/mapper_handler'

module SaxStream
  describe Internal::MapperHandler do
    let(:mapper_class) { double("mapper class") }
    let(:collector)    { double("collector") }
    let(:subject)      { Internal::MapperHandler.new(mapper_class, collector) }

    context "maps_node" do
      it "is true if name equal node name" do
        mapper_class.stub!(:node_name).and_return('client')
        subject.maps_node?('client').should be_true
      end

      it "is false if name doesnt equal node name" do
        mapper_class.stub!(:node_name).and_return('employer')
        subject.maps_node?('client').should be_false
      end
    end

    context "start_element" do

    end
  end
end