require 'sax_stream/internal/mapper_handler'

module SaxStream
  module Internal
    class ChildMapping
      attr_reader :name

      # Supported options are :to, :as & :parent_collects. See Mapper.relate documentation for more details.
      def initialize(name, options)
        @name = name.to_s
        @parent_collects = options[:parent_collects]
        process_conversion_type(options[:as])
      end

      def handler_for(node_path, collector, handler_stack, parent_object)
        node_name = node_path.split('/').last
        @mapper_classes.each do |mapper_class|
          if mapper_class.maps_node?(node_name)
            new_handler_collector = @parent_collects ? parent_object.relations[name] : collector
            return MapperHandler.new(mapper_class, new_handler_collector, handler_stack)
          end
        end
        nil
      end

      def map_value_onto_object(object, value)
      end

      private

        def arrayify(value)
          value.is_a?(Enumerable) ? value : [value]
        end

        def process_conversion_type(as)
          @mapper_classes = arrayify(as).compact
          if @mapper_classes.empty?
            raise ":as options for #{@name} field is empty, for child nodes it must be a mapper class or array of mapper classes"
          end
          @mapper_classes.each do |mapper_class|
            unless mapper_class.respond_to?(:map_key_onto_object)
              raise ":as options for #{@name} field contains #{mapper_class.inspect} which does not appear to be a valid mapper class"
            end
          end
        end
    end
  end
end