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
