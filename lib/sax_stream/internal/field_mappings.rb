module SaxStream
  module Internal
    class FieldMappings
      def initialize
        @mappings ||= CoreExtensions::OrderedHash.new
      end

      def store(key, mapping)
        key = build_key_from_array(key)
        class_mappings[key] = mapping
      end

      def class_mappings
        @mappings
      end

      def field_mapping(key, attributes = [])
        find_non_regex_mapping(key) || regex_field_mapping(key)
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
        key.include?('*') ? Regexp.new(key.gsub('*', '[^/]+')) : key
      end
    end
  end
end
