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

  def test_lex_keywords_and_identifiers
    input = <<~INPUT
    let five = 5;
    let ten = 10;

    let add = fn(x, y) {
      x + y;
    };

    let result = add(five, ten);
    INPUT
    lexer = Lexer.new(input)

    expected_tokens = [
      Token.new(TokenType::LET, 'let'),
      Token.new(TokenType::IDENT, 'five'),
      Token.new(TokenType::ASSIGN, '='),
      Token.new(TokenType::INT, '5'),
      Token.new(TokenType::SEMICOLON, ';'),

      Token.new(TokenType::LET, 'let'),
      Token.new(TokenType::IDENT, 'ten'),
      Token.new(TokenType::ASSIGN, '='),
      Token.new(TokenType::INT, '10'),
      Token.new(TokenType::SEMICOLON, ';'),

      Token.new(TokenType::LET, 'let'),
      Token.new(TokenType::IDENT, 'add'),
      Token.new(TokenType::ASSIGN, '='),
      Token.new(TokenType::FN, 'fn'),
      Token.new(TokenType::LPAREN, '('),
      Token.new(TokenType::IDENT, 'x'),
      Token.new(TokenType::COMMA, ','),
      Token.new(TokenType::IDENT, 'y'),
      Token.new(TokenType::RPAREN, ')'),
      Token.new(TokenType::LBRACE, '{'),
      Token.new(TokenType::IDENT, 'x'),
      Token.new(TokenType::PLUS, '+'),
      Token.new(TokenType::IDENT, 'y'),
      Token.new(TokenType::SEMICOLON, ';'),
      Token.new(TokenType::RBRACE, '}'),
      Token.new(TokenType::SEMICOLON, ';'),

      Token.new(TokenType::LET, 'let'),
      Token.new(TokenType::IDENT, 'result'),
      Token.new(TokenType::ASSIGN, '='),
      Token.new(TokenType::IDENT, 'add'),
      Token.new(TokenType::LPAREN, '('),
      Token.new(TokenType::IDENT, 'five'),
      Token.new(TokenType::COMMA, ','),
      Token.new(TokenType::IDENT, 'ten'),
      Token.new(TokenType::RPAREN, ')'),
      Token.new(TokenType::SEMICOLON, ';'),

      Token.new(TokenType::EOF, ''),
    ]

    expected_tokens.each do |expected_token|
      assert_equal expected_token, lexer.next_token
    end
  end
end