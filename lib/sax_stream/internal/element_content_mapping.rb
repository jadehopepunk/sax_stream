require 'sax_stream/internal/element_mapping'

module SaxStream
  module Internal
    class ElementContentMapping < ElementMapping
      def update_dom_node(object, node)
        node.content = value_from_object(object)
      end
    end
  end
end