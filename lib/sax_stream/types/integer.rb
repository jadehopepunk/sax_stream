module SaxStream
  module Types
    class Integer
      def self.parse(value)
        if value
          value = value.gsub(/[^\.0-9]/, '')
          return nil if value == ''
          Float(value).to_i
        end
      end
    end
  end
end