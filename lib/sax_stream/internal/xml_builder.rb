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
          element = find_or_insert_nested_element(doc, base, mapping.path_parts)
          mapping.update_dom_node(object, element)
          element
        end

        def find_or_insert_nested_element(doc, base, path_parts)
          part = path_parts.shift
          if part
            if part =~ /^@/
              return base
            else
              result = find_or_insert_child_element(doc, base, part)
              find_or_insert_nested_element(doc, result, path_parts)
            end
          else
            base
          end
        end

        def find_or_insert_child_element(doc, base, part)
          base.search(part).first || insert_child_element(doc, base, part)
        end

        def insert_child_element(doc, base, part)
          doc.create_element(part).tap do |element|
            base << element
          end
        end
    end
  end
end