module SaxStream
  class ImportError < Exception; end

  class ProgramError < ImportError; end
  class UnexpectedNode < ImportError; end
  class UnexpectedAttribute < ImportError; end
end