module TokenType
  ILLEGAL = 'ILLEGAL'
  EOF = 'EOF'

  # identifier + literals
  IDENT = 'IDENT'
  INT = 'INT'

  # operators
  ASSIGN = '='
  PLUS = '+'
  MINUS = '-'
  ASTERISK = '*'
  SLASH = '/'

  EQ = '=='
  NEQ = '!='
  BANG = '!'
  GT = '>'
  LT = '<'

  # delimiters
  COMMA = ','
  SEMICOLON = ';'
  LPAREN = '('
  RPAREN = ')'
  LBRACE = '{'
  RBRACE = '}'

  # keywords
  FN = 'FN'
  LET = 'LET'
  IF = 'IF'
  ELSE = 'ELSE'
  RETURN = 'RETURN'

  # @param [String] literal
  # @return [String]
  def self.from(literal)
    {
      'let' => LET,
      'fn' => FN,
      'if' => IF,
      'else' => ELSE,
      'return' => RETURN,
    }[literal] || IDENT
  end
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

  # @return [String]
  def to_s
    "{Token type=#{@type} literal=#{@literal}}"
  end
end
