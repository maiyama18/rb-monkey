require 'spec_helper'

RSpec.describe "Lexer#next_token" do
  [
    [
      "",
      [
        RMonkey::Token.new(RMonkey::TokenType::EOF, '')
      ],
    ],
    [
      "=+-*/!><(){},;",
      [
        RMonkey::Token.new(RMonkey::TokenType::ASSIGN, '='),
        RMonkey::Token.new(RMonkey::TokenType::PLUS, '+'),
        RMonkey::Token.new(RMonkey::TokenType::MINUS, '-'),
        RMonkey::Token.new(RMonkey::TokenType::ASTERISK, '*'),
        RMonkey::Token.new(RMonkey::TokenType::SLASH, '/'),
        RMonkey::Token.new(RMonkey::TokenType::BANG, '!'),
        RMonkey::Token.new(RMonkey::TokenType::GT, '>'),
        RMonkey::Token.new(RMonkey::TokenType::LT, '<'),
        RMonkey::Token.new(RMonkey::TokenType::LPAREN, '('),
        RMonkey::Token.new(RMonkey::TokenType::RPAREN, ')'),
        RMonkey::Token.new(RMonkey::TokenType::LBRACE, '{'),
        RMonkey::Token.new(RMonkey::TokenType::RBRACE, '}'),
        RMonkey::Token.new(RMonkey::TokenType::COMMA, ','),
        RMonkey::Token.new(RMonkey::TokenType::SEMICOLON, ';'),
        RMonkey::Token.new(RMonkey::TokenType::EOF, ''),
      ],
    ],
    [
      "3 == 3; 3 != 4;",
      [
        RMonkey::Token.new(RMonkey::TokenType::INT, '3'),
        RMonkey::Token.new(RMonkey::TokenType::EQ, '=='),
        RMonkey::Token.new(RMonkey::TokenType::INT, '3'),
        RMonkey::Token.new(RMonkey::TokenType::SEMICOLON, ';'),

        RMonkey::Token.new(RMonkey::TokenType::INT, '3'),
        RMonkey::Token.new(RMonkey::TokenType::NEQ, '!='),
        RMonkey::Token.new(RMonkey::TokenType::INT, '4'),
        RMonkey::Token.new(RMonkey::TokenType::SEMICOLON, ';'),
      ]
    ],
    [
      <<~INPUT ,
        let five = 5;
        let ten = 10;

        let add = fn(x, y) {
          x + y;
        };

        let result = if (ten > 9) { add(five, ten); } else { five; }
        return result;
      INPUT
      [
        RMonkey::Token.new(RMonkey::TokenType::LET, 'let'),
        RMonkey::Token.new(RMonkey::TokenType::IDENT, 'five'),
        RMonkey::Token.new(RMonkey::TokenType::ASSIGN, '='),
        RMonkey::Token.new(RMonkey::TokenType::INT, '5'),
        RMonkey::Token.new(RMonkey::TokenType::SEMICOLON, ';'),

        RMonkey::Token.new(RMonkey::TokenType::LET, 'let'),
        RMonkey::Token.new(RMonkey::TokenType::IDENT, 'ten'),
        RMonkey::Token.new(RMonkey::TokenType::ASSIGN, '='),
        RMonkey::Token.new(RMonkey::TokenType::INT, '10'),
        RMonkey::Token.new(RMonkey::TokenType::SEMICOLON, ';'),

        RMonkey::Token.new(RMonkey::TokenType::LET, 'let'),
        RMonkey::Token.new(RMonkey::TokenType::IDENT, 'add'),
        RMonkey::Token.new(RMonkey::TokenType::ASSIGN, '='),
        RMonkey::Token.new(RMonkey::TokenType::FN, 'fn'),
        RMonkey::Token.new(RMonkey::TokenType::LPAREN, '('),
        RMonkey::Token.new(RMonkey::TokenType::IDENT, 'x'),
        RMonkey::Token.new(RMonkey::TokenType::COMMA, ','),
        RMonkey::Token.new(RMonkey::TokenType::IDENT, 'y'),
        RMonkey::Token.new(RMonkey::TokenType::RPAREN, ')'),
        RMonkey::Token.new(RMonkey::TokenType::LBRACE, '{'),
        RMonkey::Token.new(RMonkey::TokenType::IDENT, 'x'),
        RMonkey::Token.new(RMonkey::TokenType::PLUS, '+'),
        RMonkey::Token.new(RMonkey::TokenType::IDENT, 'y'),
        RMonkey::Token.new(RMonkey::TokenType::SEMICOLON, ';'),
        RMonkey::Token.new(RMonkey::TokenType::RBRACE, '}'),
        RMonkey::Token.new(RMonkey::TokenType::SEMICOLON, ';'),

        RMonkey::Token.new(RMonkey::TokenType::LET, 'let'),
        RMonkey::Token.new(RMonkey::TokenType::IDENT, 'result'),
        RMonkey::Token.new(RMonkey::TokenType::ASSIGN, '='),
        RMonkey::Token.new(RMonkey::TokenType::IF, 'if'),
        RMonkey::Token.new(RMonkey::TokenType::LPAREN, '('),
        RMonkey::Token.new(RMonkey::TokenType::IDENT, 'ten'),
        RMonkey::Token.new(RMonkey::TokenType::GT, '>'),
        RMonkey::Token.new(RMonkey::TokenType::INT, '9'),
        RMonkey::Token.new(RMonkey::TokenType::RPAREN, ')'),
        RMonkey::Token.new(RMonkey::TokenType::LBRACE, '{'),
        RMonkey::Token.new(RMonkey::TokenType::IDENT, 'add'),
        RMonkey::Token.new(RMonkey::TokenType::LPAREN, '('),
        RMonkey::Token.new(RMonkey::TokenType::IDENT, 'five'),
        RMonkey::Token.new(RMonkey::TokenType::COMMA, ','),
        RMonkey::Token.new(RMonkey::TokenType::IDENT, 'ten'),
        RMonkey::Token.new(RMonkey::TokenType::RPAREN, ')'),
        RMonkey::Token.new(RMonkey::TokenType::SEMICOLON, ';'),
        RMonkey::Token.new(RMonkey::TokenType::RBRACE, '}'),
        RMonkey::Token.new(RMonkey::TokenType::ELSE, 'else'),
        RMonkey::Token.new(RMonkey::TokenType::LBRACE, '{'),
        RMonkey::Token.new(RMonkey::TokenType::IDENT, 'five'),
        RMonkey::Token.new(RMonkey::TokenType::SEMICOLON, ';'),
        RMonkey::Token.new(RMonkey::TokenType::RBRACE, '}'),

        RMonkey::Token.new(RMonkey::TokenType::RETURN, 'return'),
        RMonkey::Token.new(RMonkey::TokenType::IDENT, 'result'),
        RMonkey::Token.new(RMonkey::TokenType::SEMICOLON, ';'),

        RMonkey::Token.new(RMonkey::TokenType::EOF, ''),
      ]
    ]
  ].each do |input, expected_tokens|
    it("should lex #{input}") do
      lexer = RMonkey::Lexer.new(input)
      expected_tokens.each do |expected_token|
        expect(lexer.next_token).to eq expected_token
      end
    end
  end
end
