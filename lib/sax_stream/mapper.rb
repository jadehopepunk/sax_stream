require 'sax_stream/internal/field_mapping'
require 'sax_stream/internal/child_mapping'

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
        store_field_mapping(options[:to], Internal::FieldMapping.new(attribute_name, options))
      end

      def relate(attribute_name, options)
        store_field_mapping(options[:to] || '*', Internal::ChildMapping.new(attribute_name, options))
      end

      def node_name
        @node_name
      end

      def maps_node?(name)
        @node_name == name
      end

      def map_attribute_onto_object(object, key, value)
        map_key_onto_object(object, "@#{key}", value)
      end

      def map_element_stack_top_onto_object(object, element_stack)
        map_key_onto_object(object, element_stack.path, element_stack.content)
        element_stack.attributes.each do |key, value|
          map_key_onto_object(object, key, value)
        end
      end

      def map_key_onto_object(object, key, value)
        mapping = field_mapping(key)
        if mapping
          mapping.map_value_onto_object(object, value)
        end
      end

      def child_handler_for(key, collector, handler_stack)
        mapping = field_mapping(key)
        if mapping
          mapping.handler_for(key, collector, handler_stack)
        end
      end

      private

        def store_field_mapping(key, mapping)
          if key.include?('*')
            regex_mappings << [Regexp.new(key.gsub('*', '[^/]+')), mapping]
          else
            mappings[key] = mapping
          end
        end

        def field_mapping(key)
          mappings[key] || regex_field_mapping(key)
        end

        def regex_field_mapping(key)
          regex_mappings.each do |regex, mapping|
            return mapping if regex =~ key
          end
          nil
        end

        def regex_mappings
          @regex_mappings ||= []
        end

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

    def inspect
      "#{self.class.name}: #{attributes.inspect}"
    end


    private

      def attributes
        @attributes ||= {}
      end
  end
end