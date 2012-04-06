require 'sax_stream/internal/mapper_handler'

module SaxStream
  module Internal
    class ChildMapping
      def initialize(name, options)
        @name = name.to_s
        @mapper_classes = arrayify(options[:as])
      end

      def handler_for(name, collector, handler_stack)
        @mapper_classes.each do |mapper_class|
          if mapper_class.maps_node?(name)
            return MapperHandler.new(mapper_class, collector, handler_stack)
          end
        end
        nil
      end

      private

        def arrayify(value)
          value.is_a?(Enumerable) ? value : [value]
        end
    end
  end
end