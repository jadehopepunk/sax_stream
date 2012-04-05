require 'sax_stream/internal/field_mapping'

module SaxStream
  module Mapper
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def node(name)
        @node_name = name
      end

      def map(attribute_name, options)
        mappings[options[:to]] = Internal::FieldMapping.new(attribute_name, options)
      end

      def node_name
        @node_name
      end

      def map_attribute_onto_object(object, key, value)
        map_key_onto_object(object, "@#{key}", value)
      end

      def map_key_onto_object(object, key, value)
        mapping = mappings[key]
        if mapping
          mapping.map_value_onto_object(object, value)
        else
          raise UnexpectedAttribute, "Found unmapped attribute #{key.inspect} = #{value.inspect}"
        end
      end

      private

        def mappings
          @mappings ||= {}
        end
    end

    def []=(key, value)
      attributes[key] = value
    end

    def [](key)
      attributes[key]
    end

    private

      def attributes
        @attributes ||= {}
      end
  end
end