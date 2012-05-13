require 'sax_stream/internal/mappings/element'

module SaxStream
  module Internal
    module Mappings
      class ElementAttribute < Element
        def update_dom_node(object, node)
          node[base_attribute_name] = value_from_object(object)
        end

        private

          def base_attribute_name
            path_parts.last.sub(/^@/, '')
          end

          def find_or_insert_path_part(doc, base, part, remaining_parts)
            return base if remaining_parts.empty?
            super
          end

      end
    end
  end
end