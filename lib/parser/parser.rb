require_relative '../lexer/lexer'
require_relative '../ast/expression'
require_relative '../ast/statement'
require_relative '../ast/program'
require_relative '../error/error'

module Precedence
  LOWEST = 0
  EQUAL = 1
  COMPARISON = 2
  SUM = 3
  PRODUCT = 4
  PREFIX = 5
  CALL = 6

  def self.from(token_type)
    case token_type
    when TokenType::EQ, TokenType::NEQ
      EQUAL
    when TokenType::GT, TokenType::LT
      COMPARISON
    when TokenType::PLUS, TokenType::MINUS
      SUM
    when TokenType::ASTERISK, TokenType::SLASH
      PRODUCT
    else
      LOWEST
    end
  end
end

class Parser
  # @param [Lexer] lexer
  def initialize(lexer)
    @lexer = lexer
    @current_token = nil
    @peek_token = nil

    consume_token
    consume_token
  end

  def parse_program
    statements = []
    until @current_token.type == TokenType::EOF
      statements << parse_statement
      consume_token
    end
    Program.new(statements)
  end

  private

  def consume_token
    @current_token = @peek_token
    @peek_token = @lexer.next_token
  end

  def expect_peek(type)
    raise ParseError.new "expect token type #{type}, but got token #{@peek_token}" if type != @peek_token.type

    consume_token
  end

  def peek_precedence
    Precedence.from(@peek_token.type)
  end

  def parse_statement
    case @current_token.type
    when TokenType::LET
      parse_let_statement
    when TokenType::RETURN
      parse_return_statement
    else
      parse_expression_statement
    end
  end

  def parse_let_statement
    token = @current_token

    expect_peek(TokenType::IDENT)
    identifier = Identifier.new(@current_token, @current_token.literal)

    expect_peek(TokenType::ASSIGN)
    # TODO: parse expression
    until @current_token.type == TokenType::SEMICOLON
      consume_token
    end

    LetStatement.new(token, identifier, nil)
  end

  def parse_return_statement
    token = @current_token

    # TODO: parse expression
    until @current_token.type == TokenType::SEMICOLON
      consume_token
    end

    ReturnStatement.new(token, nil)
  end

  def parse_expression_statement
    token = @current_token

    expression = parse_expression(Precedence::LOWEST)

    consume_token if @peek_token.type == TokenType::SEMICOLON

    ExpressionStatement.new(token, expression)
  end

  def parse_expression(precedence)
    left = case @current_token.type
           when TokenType::IDENT
             parse_identifier
           when TokenType::INT
             parse_integer_literal
           when TokenType::TRUE, TokenType::FALSE
             parse_boolean_literal
           when TokenType::BANG, TokenType::MINUS
             parse_prefix_expression
           when TokenType::LPAREN
             parse_grouped_expression
           else
             throw NoParseFunctionError.new("parser has no function to parse prefix token type #{@current_token.type}")
           end

    while precedence < peek_precedence
      consume_token
      left = case @current_token.type
             when TokenType::EQ, TokenType::NEQ, TokenType::GT, TokenType::LT, TokenType::PLUS, TokenType::MINUS, TokenType::ASTERISK, TokenType::SLASH
               parse_infix_expression(left)
             else
               throw NoParseFunctionError.new("parser has no function to parse infix token type #{@current_token.type}")
             end
    end

    left
  end

  def parse_identifier
    Identifier.new(@current_token, @current_token.literal)
  end

  def parse_integer_literal
    IntegerLiteral.new(@current_token, @current_token.literal.to_i)
  end

  def parse_boolean_literal
    BooleanLiteral.new(@current_token, @current_token.literal == 'true')
  end

  def parse_prefix_expression
    token = @current_token
    operator = @current_token.literal
    consume_token
    right = parse_expression(Precedence::PREFIX)

    PrefixExpression.new(token, operator, right)
  end

  def parse_infix_expression(left)
    token = @current_token
    operator = @current_token.literal
    consume_token
    right = parse_expression(Precedence.from(token.type))

    InfixExpression.new(token, left, operator, right)
  end

  def parse_grouped_expression
    consume_token
    expression = parse_expression(Precedence::LOWEST)

    expect_peek(TokenType::RPAREN)

    expression
  end
end