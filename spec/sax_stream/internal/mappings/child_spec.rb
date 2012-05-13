require 'spec_helper'
require 'sax_stream/internal/mappings/child'

module SaxStream
  module Internal
    describe Mappings::Child do
      let(:relation)       { double("relation") }
      let(:mapper1)        { double("mapper1", :maps_node? => nil, :map_key_onto_object => nil) }
      let(:collector)      { double("collector") }
      let(:handler_stack)  { double("handler stack") }
      let(:handler)        { double("handler") }
      let(:current_object) { double("current object") }

      context "fetching handler" do
        it "is nil if has no mapper which maps nodes of this name" do
          mapping = Mappings::Child.new('catalogue', :as => mapper1)

          mapping.handler_for('banana', collector, handler_stack, current_object).should be_nil
        end

        it "builds a new handler if it has a mapper which maps nodes of this name" do
          mapper1.stub!(:maps_node?).with('product').and_return(true)
          mapping = Mappings::Child.new('catalogue', :as => mapper1)
          MapperHandler.should_receive(:new).with(mapper1, collector, handler_stack).and_return(handler)

          mapping.handler_for('product', collector, handler_stack, current_object).should == handler
        end

        it "passes in the relation as the collector if collect is true" do
          mapper1.stub!(:maps_node?).with('product').and_return(true)
          current_object.stub!(:relations).and_return({'catalogue' => relation})
          mapping = Mappings::Child.new('catalogue', :as => [mapper1], :parent_collects => true)
          MapperHandler.should_receive(:new).with(mapper1, relation, handler_stack).and_return(handler)

          mapping.handler_for('product', collector, handler_stack, current_object)
        end
      end
    end
  end
end