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
        @current_object = @mapper_class.new
      end

      def end_element(name)
        raise ProgramError unless @current_object
        raise ArgumentError unless @current_object.class.node_name == name
        @collector << @current_object
        @current_object = nil
      end

      def current_object
        @current_object
      end
    end
  end
end