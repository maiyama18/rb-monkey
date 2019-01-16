module RMonkey
  class ParseError < StandardError
  end

  class InvalidTokenError < StandardError
  end

  class NoParseFunctionError < StandardError
  end

  class EvalError < StandardError
  end
end
