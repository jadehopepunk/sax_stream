require 'sax_stream/errors'

module SaxStream
  module Internal
    class ElementStack
      class Element
        attr_accessor :name

        def initialize(name, attrs)
          @name = name
          @attrs = attrs
          @content = nil
        end

        def attributes(prefix = nil)
          prefix ||= @name
          @attrs.map do |key, value|
            ["#{prefix}/@#{key}", value]
          end
        end

        def content
          @content
        end

        def record_characters(string)
          @content ||= ''
          @content += string
        end
      end

      def initialize
        @elements = []
      end

      def top_name
        @elements.last.name if @elements.last
      end

      def push(name, attrs)
        @elements.push(Element.new(name, attrs))
        # indented_puts "push element #{name}"
      end

      def pop
        raise ProgramError, "attempting to pop an empty ElementStack" if @elements.empty?
        # indented_puts "pop element"
        @elements.pop
      end

      def empty?
        @elements.empty?
      end

      def path
        @elements.map(&:name).join('/')
      end

      def content
        @elements.last.content
      end

      def attributes
        @elements.last.attributes(path)
      end

      def record_characters(string)
        # indented_puts "  record: #{string.inspect}"
        @elements.last.record_characters(string)
      end

      private

        def indented_puts(string)
          indent = ''
          @elements.length.times { indent << '  ' }
          puts indent + string
        end
    end
  end
end