require 'sax_stream/internal/mappings/element'

module SaxStream
  module Internal
    module Mappings
      class ElementContent < Element
        def update_parent_node(builder, doc, parent, object)
          node = find_or_insert_child_element(doc, parent, path_parts.last)
          node.content = value_from_object(object)
          node
        end
      end
    end
  end
end