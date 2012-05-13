require 'sax_stream/internal/mappings/element'

module SaxStream
  module Internal
    module Mappings
      class ElementContent < Element
        def update_dom_node(object, node)
          node.content = value_from_object(object)
        end
      end
    end
  end
end