module SaxStream
  module Internal
    class FieldMapping
      def initialize(name, options)
        @name = name.to_s
        @path = options[:to]
      end

      def map_value_onto_object(object, value)
        object[@name] = value
      end
    end
  end
end