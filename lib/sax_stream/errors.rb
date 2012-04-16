module SaxStream
  class ImportError < Exception; end

  class ProgramError < ImportError; end

  class ParsingError < ImportError; end
  class UnexpectedNode < ParsingError; end
  class UnexpectedAttribute < ParsingError; end
end