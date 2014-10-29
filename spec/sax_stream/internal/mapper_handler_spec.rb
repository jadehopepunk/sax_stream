require 'spec_helper'
require 'sax_stream/internal/mapper_handler'

module SaxStream
  describe Internal::MapperHandler do
    let(:new_mapped_object) { double("instance of mapper class", :node_name => 'foobar', :should_collect? => false, :node_name= => nil) }
    let(:element_stack)     { Internal::ElementStack.new }
    let(:mapper_class)      { double("mapper class", :new => new_mapped_object, :child_handler_for => nil, :maps_node? => false) }
    let(:collector)         { double("collector") }
    let(:handler_stack)     { double("HandlerStack", :pop => nil) }
    let(:subject)           { Internal::MapperHandler.new(mapper_class, collector, handler_stack, element_stack) }

    context "maps_node" do
      it "is true if mapper class maps node name" do
        mapper_class.stub!(:maps_node?).with('client').and_return(true)
        subject.maps_node?('client').should be_true
      end

      it "is false if mapper class doesnt map node name" do
        mapper_class.stub!(:maps_node?).with('client').and_return(false)
        subject.maps_node?('client').should be_false
      end
    end

    context "start_element and end_element" do
      context "for main mapper class element" do
        before do
          mapper_class.stub!(:maps_node?).with('foobar').and_return(true)
        end

        it "instantiates a mapped object on start" do
          subject.start_element('foobar')
          subject.current_object.should == new_mapped_object
        end

        it "sets attributes on the mapped object on start" do
          mapper_class.should_receive(:map_attribute_onto_object).with(new_mapped_object, 'a', 'b')
          subject.start_element('foobar', [['a', 'b']])
        end

        it "maps the element on end" do
          subject.start_element('foobar')
          subject.characters('fish')
          mapper_class.should_receive(:map_key_onto_object).with(new_mapped_object, '', 'fish')
          subject.end_element('foobar')
        end
      end

      context "for another element" do
        before do
          mapper_class.stub!(:maps_node?).with('foobar').and_return(true)
          mapper_class.stub!(:node_name).and_return('foobar')
        end

        it "maps element stack onto mapped object on end" do
          subject.start_element('foobar')
          mapper_class.should_receive(:map_element_stack_top_onto_object).with(new_mapped_object, anything)

          subject.start_element('barfoo')
          subject.end_element('barfoo')
        end

        it "raises an error if it gets another element before the mapped element" do
          lambda {
            subject.start_element('barfoo')
          }.should raise_error(ProgramError)
        end

        context "if the element matches a child attribute" do
          let(:post_handler) { double("post handler", :start_element => nil) }

          before do
            subject.start_element('foobar')
            mapper_class.stub!(:child_handler_for).with('post', collector, handler_stack, anything).and_return(post_handler)
            handler_stack.stub(:push)
          end

          it "pushes a new handler onto the sax handling stack" do
            handler_stack.should_receive(:push).with(post_handler)
            subject.start_element('post')
          end

          it "calls start_element on the new handler" do
            post_handler.should_receive(:start_element).with('post', [['a', 'b']])
            subject.start_element('post', [['a', 'b']])
          end
        end
      end
    end

  end
end