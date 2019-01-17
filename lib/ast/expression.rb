require_relative './node'

module RMonkey
  class Expression < Node
    attr_accessor :token
  end

  class Identifier < Expression
    attr_accessor :name

    # @param [Token] token
    # @param [String] name
    def initialize(token, name)
      @token = token
      @name = name
    end

    # @return [String]
    def to_s
      name
    end
  end

  class IntegerLiteral < Expression
    attr_accessor :value

    # @param [Token] token
    # @param [Integer] value
    def initialize(token, value)
      @token = token
      @value = value
    end

    # @return [String]
    def to_s
      value.to_s
    end
  end

  class BooleanLiteral < Expression
    attr_accessor :value

    # @param [Token] token
    # @param [TrueClass/FalseClass] value
    def initialize(token, value)
      @token = token
      @value = value
    end

    # @return [String]
    def to_s
      value.to_s
    end
  end

  class PrefixExpression < Expression
    attr_accessor :operator, :right

    # @param [Token] token
    # @param [String] operator
    # @param [Expression] right
    def initialize(token, operator, right)
      @token = token
      @operator = operator
      @right = right
    end

    def to_s
      "(#{operator}#{right})"
    end
  end

  class InfixExpression < Expression
    attr_accessor :left, :operator, :right

    # @param [Token] token
    # @param [Expression] left
    # @param [String] operator
    # @param [Expression] right
    def initialize(token, left, operator, right)
      @token = token
      @left = left
      @operator = operator
      @right = right
    end

    def to_s
      "(#{left} #{operator} #{right})"
    end
  end

  class IfExpression < Expression
    attr_accessor :condition, :consequence, :alternative

    # @param [Token] token
    # @param [Expression] condition
    # @param [BlockStatement] consequence
    # @param [BlockStatement] alternative
    def initialize(token, condition, consequence, alternative = nil)
      @token = token
      @condition = condition
      @consequence = consequence
      @alternative = alternative
    end

    def to_s
      s = "if #{condition} #{consequence}"
      alternative ? s += " else #{alternative}" : s
    end
  end

  class FunctionLiteral < Expression
    attr_accessor :parameters, :body

    # @param [Token] token
    # @param [[]Identifier] parameters
    # @param [BlockStatement] body
    def initialize(token, parameters, body)
      @token = token
      @parameters = parameters
      @body = body
    end

    def to_s
      "fn (#{parameters.map(&:name).join(', ')}) { #{body} }"
    end
  end

  class CallExpression < Expression
    attr_accessor :function, :arguments

    # @param [Token] token
    # @param [Expression] function # FunctionLiteral or Identifier
    # @param [[]Expression] arguments
    def initialize(token, function, arguments)
      @token = token
      @function = function
      @arguments = arguments
    end

    def to_s
      "#{function}(#{arguments.map(&:to_s).join(', ')})"
    end
  end
end
