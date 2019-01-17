require_relative './node'

module RMonkey
  class Statement < Node
    attr_accessor :token
  end

  class LetStatement < Statement
    attr_accessor :identifier, :expression

    def initialize(token, identifier, expression)
      @token = token
      @identifier = identifier
      @expression = expression
    end

    def to_s
      "#{token.literal} #{identifier} = #{expression}"
    end
  end

  class ReturnStatement < Statement
    attr_accessor :expression

    def initialize(token, expression)
      @token = token
      @expression = expression
    end

    def to_s
      "#{token.literal} #{expression}"
    end
  end

  class ExpressionStatement < Statement
    attr_accessor :expression

    def initialize(token, expression)
      @token = token
      @expression = expression
    end

    def to_s
      "#{expression}"
    end
  end

  class BlockStatement < Statement
    attr_accessor :statements

    def initialize(token, statements)
      @token = token
      @statements = statements
    end

    def to_s
      statements.map(&:to_s).join
    end
  end
end
