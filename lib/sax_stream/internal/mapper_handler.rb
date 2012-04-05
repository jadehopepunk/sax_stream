module SaxStream
  module Internal
    class MapperHandler
      def initialize(mapper_class, collector)
        raise ArgumentError unless collector
        raise ArgumentError unless mapper_class

        @mapper_class = mapper_class
        @collector = collector
      end

      def maps_node?(node_name)
        @mapper_class.node_name == node_name
      end

      def start_element(name, attrs = [])
        raise ArgumentError, "Received start element #{name.inspect} which I don't handle" unless maps_node?(name)
        @current_object = @mapper_class.new
        attrs.each do |key, value|
          @mapper_class.map_attribute_onto_object(@current_object, key, value)
        end
      end

      def end_element(name)
        raise ProgramError unless @current_object
        raise ArgumentError, "received end element event for #{name.inspect} but currently processing #{@current_object.class.node_name.inspect}" unless @current_object.class.node_name == name
        @collector << @current_object
        @current_object = nil
      end

      def current_object
        @current_object
      end
    end
  end
end