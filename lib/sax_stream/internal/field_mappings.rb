module SaxStream
  module Internal
    class FieldMappings
      class MappingOptions
        def initialize(element, key)
          @element = element
          @key = key
          @attributes = parse_attributes(key) if key.is_a?(String)
        end

        def element
          @element
        end

        def allows_mapping?(key, attributes)
          compare_attributes(attributes)
        end

        def method_missing(name, *params)
          @element.send(name, *params)
        end

        private

        def parse_attributes(key)
          matches = key.match(/\[(.*)\]/)
          if matches
            return hashify_attribute(matches[1])
          end
        end

        def hashify_attribute(string)
          parts = string.split('=')
          {parts[0] => parts[1]}
        end

        def compare_attributes(attributes)
          return true unless @attributes

          attributes_hash = Hash[*attributes.flatten]

          result = !@attributes.detect do |key, value|
            inner_result = attributes_hash[key] != value
            inner_result
          end
          result
        end
      end

      def initialize
        @mappings ||= CoreExtensions::OrderedHash.new
      end

      def store(key, mapping)
        parsed_key = build_key_from_array(key)
        new_value = MappingOptions.new(mapping, key)

        if class_mappings[parsed_key]
          unless class_mappings[parsed_key].is_a?(Array)
            old_value = class_mappings[parsed_key]
            class_mappings[parsed_key] = [old_value]
          end
          class_mappings[parsed_key] << new_value
        else
          class_mappings[parsed_key] = new_value
        end
      end

      def class_mappings
        @mappings
      end

      def field_mapping(key, attributes = [])
        result = find_non_regex_mapping(key) || regex_field_mapping(key)

        unless result.is_a?(Array)
          result = [result]
        end
        result.compact!

        result.detect do |one_result|
          one_result.element if one_result.allows_mapping?(key, attributes)
        end
      end

      private

      def find_non_regex_mapping(key)
        class_mappings[key]
      end

      def regex_field_mapping(key)
        regex_mappings.each do |regex, mapping|
          return mapping if regex =~ key
        end
        nil
      end

      def regex_mappings
        @regex_mappings ||= class_mappings.reject do |key, mapping|
          !key.is_a?(Regexp)
        end
      end

      def build_key_from_array(key_array)
        if key_array.is_a?(Array)
          joined_key = "(#{key_array.join('|')})".gsub('*', '[^/]+')
          Regexp.new(joined_key)
        else
          build_key_regex(key_array)
        end
      end

      def build_key_regex(key)
        if key.include?('*')
          Regexp.new(key.gsub('*', '[^/]+'))
        else
          key.sub(/\[.*\]/, '')
        end
      end
    end
  end
end
