module SaxStream
  module Internal
    class MapperHandler
      def initialize(mapper_class, collector)
        @mapper_class = mapper_class
        @collector = collector
      end

      def maps_node?(node_name)
        @mapper_class.node_name == node_name
      end

      def start_element(name, attrs)
      end
    end
  end
end