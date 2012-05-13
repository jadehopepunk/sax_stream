require 'sax_stream/internal/element_mapping'

module SaxStream
  module Internal
    class ElementAttributeMapping < ElementMapping
      def update_dom_node(object, node)
        node[base_attribute_name] = value_from_object(object)
      end

      private

        def base_attribute_name
          path_parts.last.sub(/^@/, '')
        end
    end
  end
end