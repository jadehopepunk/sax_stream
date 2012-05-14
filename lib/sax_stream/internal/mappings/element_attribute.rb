require 'sax_stream/internal/mappings/element'

module SaxStream
  module Internal
    module Mappings
      class ElementAttribute < Element
        def update_parent_node(builder, doc, parent, object)
          parent[base_attribute_name] = value_from_object(object)
          parent
        end

        private

          def base_attribute_name
            path_parts.last.sub(/^@/, '')
          end
      end
    end
  end
end