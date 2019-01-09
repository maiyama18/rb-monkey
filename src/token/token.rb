require_relative './token_type'

class Token
  attr_accessor :type, :literal

  # @param [String] type
  # @param [String] literal
  def initialize(type, literal)
    raise "invalid token type #{type}" unless TokenType.constants.include?(type.to_sym)

    @type = type
    @literal = literal
  end
end
