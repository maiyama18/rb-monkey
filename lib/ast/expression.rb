require_relative './node'

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
    @name
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
    @value.to_s
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
    @value.to_s
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
    "(#{@operator}#{@right})"
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
    "(#{@left} #{@operator} #{@right})"
  end
end

