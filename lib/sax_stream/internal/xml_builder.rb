require 'nokogiri'

module SaxStream
  module Internal
    class XmlBuilder
      def build_xml_for(object)
        mappings = object.mappings

        doc = Nokogiri::XML::Document.new
        base = add_base_element(doc, object)
        object.mappings.each do |mapping|
          add_mapping(doc, base, object, mapping)
        end

        # noko_builder = Nokogiri::XML::Builder.new
        # noko_builder.send(object.node_name, base_attributes_hash(object, mappings))
        # # do |xml|
        # #   element_mappings(mappings).each do |mapping|
        # #     map_child_element(xml, mapping, object, mapping.path_parts)
        # #   end
        # # end
        # raise noko_builder.doc.inspect
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
            result = find_or_insert_child_element(doc, base, part)
            find_or_insert_nested_element(doc, result, path_parts)
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

        # def map_child_element(xml, mapping, object, path_parts)
        #   part = path_parts.shift
        #   if path_parts.length == 1 && path_parts.first =~ /^@/
        #     # We are mapping an attribute
        #     value = mapping.value_from_object(object)
        #     attribute_key = path_parts.first.sub(/^@/, '')
        #     xml.send(part, attribute_key => value)
        #   elsif path_parts.empty?
        #     value = mapping.value_from_object(object)
        #     xml.send(part, value)
        #   else
        #     xml.send(part, nil) do |child_xml|
        #       map_child_element(child_xml, mapping, object, path_parts)
        #     end
        #   end
        # end
        #
        # def base_attributes_hash(object, mappings)
        #   attributes_array = base_attribute_mappings(mappings).map do |mapping|
        #     [mapping.base_attribute_name, mapping.value_from_object(object)]
        #   end
        #   Hash[*attributes_array.flatten]
        # end
        #
        # def base_attribute_mappings(mappings)
        #   mappings.select(&:is_base_attribute?)
        # end
        #
        # def element_mappings(mappings)
        #   mappings.select(&:is_element?)
        # end
    end
  end
end