require 'sax_stream/internal/mapper_handler'
require 'sax_stream/internal/singular_relationship_collector'

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
            return MapperHandler.new(mapper_class, child_collector(parent_object, collector), handler_stack)
          end
        end
        nil
      end

      def is_attribute?
        false
      end

      def is_base_attribute?
        false
      end

      def is_element?
        false
      end

      def map_value_onto_object(object, value)
      end

      def build_empty_relation
        [] if @plural
      end

      private

        def child_collector(parent_object, collector)
          if @parent_collects
            if @plural
              parent_object.relations[name]
            else
              SingularRelationshipCollector.new(parent_object, @name)
            end
          else
            collector
          end
        end

        def arrayify(value)
          value.is_a?(Enumerable) ? value : [value]
        end

        def process_conversion_type(as)
          @plural = as.is_a?(Enumerable)
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