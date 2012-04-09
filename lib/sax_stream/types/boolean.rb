module SaxStream
  module Types
    class Boolean
      def self.parse(value)
        if value
          value = value.strip
          return nil if value == ''
          !!(value =~ /^(yes|true|1)$/i)
        end
      end
    end
  end
end