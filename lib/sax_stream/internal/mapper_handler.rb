require 'sax_stream/internal/element_stack'

module SaxStream
  module Internal
    # Handles SAX events on behalf of a mapper class. Expects the first event to be start_element, and then
    # uses other events to build the element until end_element is received, at which time the completed
    # object will be sent off to the collector.
    #
    # Also handles child elements which use their own mapper class, and will pass off SAX control to other
    # handlers to achieve this.
    class MapperHandler
      attr_accessor :stack
      attr_reader :mapper_class, :collector

      # mapper_class::  A class which has had SaxStream::Mapper included in it.
      #
      # collector::     The collector object used for this parsing run. This gets passed around to everything
      #                 that needs it.
      #
      # handler_stack:: The current stack of Sax handling objects for this parsing run. This gets passed around
      #                 to everything that needs it. This class does not need to push itself onto the stack,
      #                 that has already been done for it. If it pushes other handlers onto the stack, then
      #                 it will no longer be handling SAX events itself until they get popped off.
      #
      # element_stack:: Used internally by this object to collect XML elements that have been parsed which may
      #                 be used when mapping this class. You don't need to pass this in except for dependency
      #                 injection purposes.
      def initialize(mapper_class, collector, handler_stack, element_stack = ElementStack.new)
        raise ArgumentError, "no collector" unless collector
        raise ArgumentError, "no mapper class" unless mapper_class
        raise ArgumentError, "no handler stack" unless handler_stack
        raise ArgumentError, "no element stack" unless element_stack

        @mapper_class = mapper_class
        @collector = collector
        @element_stack = element_stack
        @stack = handler_stack
      end

      def maps_node?(node_name)
        @mapper_class.maps_node?(node_name)
      end

      def start_element(name, attrs = [])
        start_current_object(name, attrs) || start_child_node(name, attrs) || start_child_data(name, attrs)
      end

      def end_element(name)
        pop_element_stack(name) || end_current_object(name)
      end

      def cdata_block(string)
        characters(string)
      end

      def characters(string)
        unless @element_stack.empty?
          @element_stack.record_characters(string)
        end
      end

      def current_object
        @current_object
      end

      private

        def start_current_object(name, attrs)
          if maps_node?(name)
            @current_object = @mapper_class.new
            attrs.each do |key, value|
              @mapper_class.map_attribute_onto_object(@current_object, key, value)
            end
            @current_object
          end
        end

        def start_child_node(name, attrs)
          handler = @mapper_class.child_handler_for(name, @collector, @stack)
          if handler
            @stack.push(handler)
            handler.start_element(name, attrs)
            handler
          end
        end

        def start_child_data(name, attrs)
          raise ProgramError, "received child element #{name.inspect} before receiving main expected node #{@mapper_class.node_name.inspect}" unless current_object
          @element_stack.push(name, attrs)
        end

        def pop_element_stack(name)
          unless @element_stack.empty?
            raise ProgramError "received end element event for #{name.inspect} but currently processing #{@element_stack.top_name.inspect}" unless @element_stack.top_name == name
            @mapper_class.map_element_stack_top_onto_object(@current_object, @element_stack)
            @element_stack.pop
          end
        end

        def end_current_object(name)
          raise ProgramError unless @current_object
          raise ArgumentError, "received end element event for #{name.inspect} but currently processing #{@current_object.class.node_name.inspect}" unless @current_object.class.node_name == name
          @collector << @current_object
          @stack.pop(self)
          @current_object = nil
        end
    end
  end
end