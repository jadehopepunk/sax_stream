require 'sax_stream/internal/mappings/element'

module SaxStream
  module Internal
    module Mappings
      class Wildcard < ElementAttribute
        def initialize()
        end

        def map_value_onto_object(object, key, value)
          name = key.sub(/^@/, '')

          write_value_to_object object, value, name
        end

        def allows_mapping?(key, attributes)
          key[0] == '@'
        end

        private

        def base_attribute_name
          path_parts.last.sub(/^@/, '')
        end
      end
    end
  end
end