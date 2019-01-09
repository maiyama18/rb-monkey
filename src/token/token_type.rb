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
