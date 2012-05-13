module SaxStream
  module Internal
    class ElementContentMapping
      def initialize(name, options = {})
        @name = name.to_s
        @path = options[:to]
        process_conversion_type(options[:as])
      end

      def map_value_onto_object(object, value)
        if value && @parser
          value = @parser.parse(value)
        end
        if object.respond_to?(setter_method)
          object.send(setter_method, value)
        else
          object[@name] = value
        end
      end

      def value_from_object(object)
        object[@name]
      end

      def handler_for(name, collector, handler_stack, parent_object)
      end

      def is_attribute?
        path_parts.last =~ /^@/
      end

      def is_base_attribute?
        @path =~ /^@/
      end

      def is_element?
        !is_base_attribute?
      end

      def base_attribute_name
        @path.sub(/^@/, '')
      end

      def path_parts
        @path.split('/')
      end

      def update_dom_node(object, node)
        node.content = value_from_object(object)
      end

      private
        def setter_method
          "#{@name}=".to_sym
        end

        def process_conversion_type(as)
          if as
            if as.respond_to?(:parse)
              @parser = as
            else
              raise ArgumentError, ":as options for #{@name} field is a #{as.inspect} which must respond to parse"
            end
          end
        end
    end
  end
end