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

      class RootElement < Element
        def initialize
          super(nil, [])
        end
      end

      def initialize
        @elements = []
      end

      def push(name, attrs)
        @elements.push(Element.new(name, attrs))
        # indented_puts "push element #{name}"
      end

      def push_root
        @elements.push(RootElement.new)
      end

      def pop(name = nil)
        raise ProgramError, "attempting to pop an empty ElementStack" if @elements.empty?
        if name && @element_stack.top_name != name
          raise ProgramError "received popping element for #{name.inspect} but currently processing #{path.inspect}"
        end
        # indented_puts "pop element"
        @elements.pop
      end

      def empty?
        @elements.length <= 1
      end

      def path
        return nil if @elements.empty?
        @elements.map(&:name).compact.join('/')
      end

      def content
        @elements.last.content
      end

      def attributes
        @elements.last.attributes(path)
      end

      def record_characters(string)
        # indented_puts "  record: #{string.inspect}"
        if @elements.last
          @elements.last.record_characters(string)
        end
      end

      private

        def top_name
          @elements.last.name if @elements.last
        end

        def indented_puts(string)
          indent = ''
          @elements.length.times { indent << '  ' }
          puts indent + string
        end
    end
  end
end