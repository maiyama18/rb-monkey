class Token
  attr_accessor :type, :literal

  # @param [String] type
  # @param [String] literal
  def initialize(type, literal)
    raise "invalid token type #{type}" if TokenType.constants.include?(type)

    @type = type
    @literal = literal
  end
end