module SaxStream
  module Types
    class Decimal
      def self.parse(value)
        if value
          value = value.gsub(/[^\-\.0-9]/, '')
          return nil if value == ''
          Float(value)
        end
      rescue ArgumentError
        nil
      end
    end
  end
end