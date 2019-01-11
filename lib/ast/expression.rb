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

  def to_s
    @name
  end
end