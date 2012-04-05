module SaxStream
  module Internal
    class FieldMapping
      def initialize(name, options)
        @name = name
        @path = options[:to]
      end

      def map_value_onto_object(object, value)
        object[@name.to_s] = value
      end
    end
  end
end