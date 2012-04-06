module SaxStream
  module Internal
    class FieldMapping
      def initialize(name, options = {})
        @name = name.to_s
        @path = options[:to]
        process_conversion_type(options[:as])
      end

      def map_value_onto_object(object, value)
        if value && @parser
          value = @parser.parse(value)
        end
        object[@name] = value
      end

      def handler_for(name, collector, handler_stack)
      end

      private

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