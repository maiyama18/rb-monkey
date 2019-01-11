module TokenType
  ILLEGAL = 'ILLEGAL'
  EOF = 'EOF'

  # identifier + literals
  IDENT = 'IDENT'
  INT = 'INT'

  # operators
  ASSIGN = '='
  PLUS = '+'

  # delimiters
  COMMA = ','
  SEMICOLON = ';'
  LPAREN = '('
  RPAREN = ')'
  LBRACE = '{'
  RBRACE = '}'

  # keywords
  FUNCTION = 'FUNCTION'
  LET = 'LET'
end

class Token
  attr_accessor :type, :literal

  # @param [String] type
  # @param [String] literal
  def initialize(type, literal)
    raise "invalid token type #{type}" unless TokenType.constants.map {|constant| TokenType.const_get(constant)}.include?(type)

    @type = type
    @literal = literal
  end

  # @return [True/False]
  def ==(other)
    @type == other.type && @literal == other.literal
  end
end
