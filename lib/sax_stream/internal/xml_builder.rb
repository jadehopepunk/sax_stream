require 'nokogiri'

module SaxStream
  module Internal
    class XmlBuilder
      def build_xml_for(object, encoding = nil)
        mappings = object.mappings

        doc = Nokogiri::XML::Document.new
        doc.encoding = (encoding || 'UTF-8')
        base = add_base_element(doc, object)
        object.mappings.each do |mapping|
          add_mapping(doc, base, object, mapping)
        end
        doc.to_xml
      end

      private

        def add_base_element(doc, object)
          doc << doc.create_element(object.node_name)
        end

        def add_mapping(doc, base, object, mapping)
          parent = mapping.find_or_insert_parent_node(doc, base)
          mapping.update_parent_node(self, doc, parent, object)
        end
    end
  end
end