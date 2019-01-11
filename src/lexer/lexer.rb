require 'set'
require_relative '../../src/token/token'

class Lexer
  SPACE_CHARS = Set.new([' ', "\t", "\r", "\n"])

  # @param [String] input
  def initialize(input)
    @input = input
    @position = 0
    @peek_position = 1
    @char = input.length.zero? ? '' : input[0]
  end

  # @return [Token]
  def next_token
    skip_spaces

    case @char
    when '='
      token = Token.new(TokenType::ASSIGN, '=')
    when '+'
      token = Token.new(TokenType::PLUS, '+')
    when '('
      token = Token.new(TokenType::LPAREN, '(')
    when ')'
      token = Token.new(TokenType::RPAREN, ')')
    when '{'
      token = Token.new(TokenType::LBRACE, '{')
    when '}'
      token = Token.new(TokenType::RBRACE, '}')
    when ','
      token = Token.new(TokenType::COMMA, ',')
    when ';'
      token = Token.new(TokenType::SEMICOLON, ';')
    when /\d/
      token = read_integer
    when /\w/
      token = read_identifier
    when ''
      token = Token.new(TokenType::EOF, '')
    else
      token = Token.new(TokenType::ILLEGAL, '')
    end

    consume_char
    token
  end

  private def consume_char
    @position += 1
    @peek_position += 1

    @char = @position >= @input.length ? '' : @input[@position]
  end

  private def peek_char
    @peek_position >= @input.length ? '' : @input[@peek_position]
  end

  private def skip_spaces
    while SPACE_CHARS.include?(@char)
      consume_char
    end
  end

  private def read_integer
    start = @position
    consume_char while peek_char.match(/\d/)

    Token.new(TokenType::INT, @input[start..@position])
  end

  private def read_identifier
    start = @position
    consume_char while peek_char.match(/\w/)

    literal = @input[start..@position]
    type = TokenType.from(literal)

    Token.new(type, @input[start..@position])
  end
end