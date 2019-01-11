require 'minitest/autorun'
require_relative '../../src/lexer/lexer'

class LexerTest < Minitest::Test
  def test_lex_single_char_tokens
    input = '=+(){},;'
    lexer = Lexer.new(input)

    expected_tokens = [
      Token.new(TokenType::ASSIGN, '='),
      Token.new(TokenType::PLUS, '+'),
      Token.new(TokenType::LPAREN, '('),
      Token.new(TokenType::RPAREN, ')'),
      Token.new(TokenType::LBRACE, '{'),
      Token.new(TokenType::RBRACE, '}'),
      Token.new(TokenType::COMMA, ','),
      Token.new(TokenType::SEMICOLON, ';'),
      Token.new(TokenType::EOF, ''),
    ]

    expected_tokens.each do |expected_token|
      assert_equal expected_token, lexer.next_token
    end
  end
end