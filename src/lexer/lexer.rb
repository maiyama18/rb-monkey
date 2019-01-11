require 'set'
require_relative '../../src/token/token'

class Lexer
  SPACE_CHARS = Set.new([' ', '\t', '\r', '\n'])

  # @param [String] input
  def initialize(input)
    @input = input
    @position = 0
    @peek_position = 1
    @char = input.length.zero? ? '' : input[0]
  end

  # @return [Token]
  def next_token
    char = @char
    consume_char
    skip_spaces

    case char
    when '='
      Token.new(TokenType::ASSIGN, '=')
    when '+'
      Token.new(TokenType::PLUS, '+')
    when '('
      Token.new(TokenType::LPAREN, '(')
    when ')'
      Token.new(TokenType::RPAREN, ')')
    when '{'
      Token.new(TokenType::LBRACE, '{')
    when '}'
      Token.new(TokenType::RBRACE, '}')
    when ','
      Token.new(TokenType::COMMA, ',')
    when ';'
      Token.new(TokenType::SEMICOLON, ';')
    when ''
      Token.new(TokenType::EOF, '')
    else
      Token.new(TokenType::ILLEGAL, '')
    end
  end

  private def consume_char
    @position += 1
    @peek_position += 1

    @char = @position >= @input.length ? '' : @input[@position]
  end

  private def skip_spaces
    while SPACE_CHARS.include?(@char)
      consume_char
    end
  end
end