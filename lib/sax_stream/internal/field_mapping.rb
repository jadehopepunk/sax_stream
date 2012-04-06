module SaxStream
  module Internal
    class FieldMapping
      def initialize(name, options = {})
        @name = name.to_s
        @path = options[:to]
        @type_converter = options[:as]
        if @type_converter && !@type_converter.respond_to?(:parse)
          raise ArgumentError, ":as options for #{name} field is a #{@type_converter.inspect} which doesn't respond to parse"
        end
      end

      def map_value_onto_object(object, value)
        if value && @type_converter
          value = @type_converter.parse(value)
        end
        object[@name] = value
      end
    end
  end
end