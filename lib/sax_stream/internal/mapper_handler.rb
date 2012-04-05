require 'sax_stream/internal/element_stack'

module SaxStream
  module Internal
    class MapperHandler
      def initialize(mapper_class, collector)
        raise ArgumentError unless collector
        raise ArgumentError unless mapper_class

        @mapper_class = mapper_class
        @collector = collector
        @element_stack = ElementStack.new
      end

      def maps_node?(node_name)
        @mapper_class.node_name == node_name
      end

      def start_element(name, attrs = [])
        start_current_object(name, attrs) || start_relative_child(name, attrs)
      end

      def end_element(name)
        pop_element_stack(name) || end_current_object(name)
      end

      def current_object
        @current_object
      end

      private

        def start_current_object(name, attrs)
          if maps_node?(name)
            puts "started object #{name}"
            @current_object = @mapper_class.new
            attrs.each do |key, value|
              @mapper_class.map_attribute_onto_object(@current_object, key, value)
            end
            @current_object
          end
        end

        def start_relative_child(name, attrs)
          puts "started element #{name}"
          @element_stack.push(name, attrs)
        end

        def pop_element_stack(name)
          unless @element_stack.empty?
            puts "ended element #{name}"
            raise ProgramError "received end element event for #{name.inspect} but currently processing #{@element_stack.top_name.inspect}" unless @element_stack.top_name == name
            @mapper_class.map_element_stack_top_onto_object(@current_object, @element_stack)
            @element_stack.pop
          end
        end

        def end_current_object(name)
          puts "ended object #{name}"
          raise ProgramError unless @current_object
          raise ArgumentError, "received end element event for #{name.inspect} but currently processing #{@current_object.class.node_name.inspect}" unless @current_object.class.node_name == name
          @collector << @current_object
          @current_object = nil
        end
    end
  end
end