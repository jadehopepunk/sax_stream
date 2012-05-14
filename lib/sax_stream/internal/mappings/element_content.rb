require 'sax_stream/internal/mappings/element'

module SaxStream
  module Internal
    module Mappings
      class ElementContent < Element
        def initialize(name, options = {})
          @cdata = options[:cdata]
          super
        end

        def update_parent_node(builder, doc, parent, object)
          node = find_or_insert_child_element(doc, parent, path_parts.last)
          value = value_from_object(object)
          if @cdata
            node.add_child(Nokogiri::XML::CDATA.new(doc, value.to_s))
          else
            node.content = value.to_s
          end
          node
        end
      end
    end
  end
end