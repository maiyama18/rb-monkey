require 'minitest/autorun'
require_relative '../../src/lexer/lexer'

class LexerTest < Minitest::Test
  def test_lex_single_char_tokens
    input = '=+-*/!><(){},;'
    lexer = Lexer.new(input)

    expected_tokens = [
      Token.new(TokenType::ASSIGN, '='),
      Token.new(TokenType::PLUS, '+'),
      Token.new(TokenType::MINUS, '-'),
      Token.new(TokenType::ASTERISK, '*'),
      Token.new(TokenType::SLASH, '/'),
      Token.new(TokenType::BANG, '!'),
      Token.new(TokenType::GT, '>'),
      Token.new(TokenType::LT, '<'),
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

  def test_lex_multiple_char_tokens
    input = '3 == 3; 3 != 4;'
    lexer = Lexer.new(input)

    expected_tokens = [
      Token.new(TokenType::INT, '3'),
      Token.new(TokenType::EQ, '=='),
      Token.new(TokenType::INT, '3'),
      Token.new(TokenType::SEMICOLON, ';'),

      Token.new(TokenType::INT, '3'),
      Token.new(TokenType::NEQ, '!='),
      Token.new(TokenType::INT, '4'),
      Token.new(TokenType::SEMICOLON, ';'),
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

    let result = if (ten > 9) { add(five, ten); } else { five; }
    return result;
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
      Token.new(TokenType::IF, 'if'),
      Token.new(TokenType::LPAREN, '('),
      Token.new(TokenType::IDENT, 'ten'),
      Token.new(TokenType::GT, '>'),
      Token.new(TokenType::INT, '9'),
      Token.new(TokenType::RPAREN, ')'),
      Token.new(TokenType::LBRACE, '{'),
      Token.new(TokenType::IDENT, 'add'),
      Token.new(TokenType::LPAREN, '('),
      Token.new(TokenType::IDENT, 'five'),
      Token.new(TokenType::COMMA, ','),
      Token.new(TokenType::IDENT, 'ten'),
      Token.new(TokenType::RPAREN, ')'),
      Token.new(TokenType::SEMICOLON, ';'),
      Token.new(TokenType::RBRACE, '}'),
      Token.new(TokenType::ELSE, 'else'),
      Token.new(TokenType::LBRACE, '{'),
      Token.new(TokenType::IDENT, 'five'),
      Token.new(TokenType::SEMICOLON, ';'),
      Token.new(TokenType::RBRACE, '}'),

      Token.new(TokenType::RETURN, 'return'),
      Token.new(TokenType::IDENT, 'result'),
      Token.new(TokenType::SEMICOLON, ';'),

      Token.new(TokenType::EOF, ''),
    ]

    expected_tokens.each do |expected_token|
      assert_equal expected_token, lexer.next_token
    end
  end
end