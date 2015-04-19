require 'sax_stream/internal/mappings/element_attribute'

module SaxStream
  module Internal
    module Mappings
      class Wildcard < ElementAttribute
        def initialize(options = {})
          @recursive = options[:recursive]
        end

        def map_value_onto_object(object, key, value)
          child_parts = key.split('/')
          name_part = child_parts.shift

          if child_parts.empty?
            name = scrub_attribute_name name_part
            write_value_to_object object, value, name
          elsif @recursive
            object[name_part] ||= {}
            write_into_hash(object[name_part], child_parts, value)
          end
        end

        def allows_mapping?(key, attributes)
          leaf = key.split('/').last
          leaf && leaf[0] == '@'
        end

        private

        def base_attribute_name
          path_parts.last.sub(/^@/, '')
        end

        def write_into_hash(hash, keys, value)
          keys.each_with_index do |key, index|
            if index == keys.length - 1
              hash[scrub_attribute_name(key)] = value
            else
              hash[key] ||= {}
              hash = hash[key]
            end
          end
        end

        def scrub_attribute_name(key)
          key.sub(/^@/, '')
        end
      end
    end
  end
end