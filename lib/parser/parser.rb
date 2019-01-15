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
end

class Parser
  # @param [Lexer] lexer
  def initialize(lexer)
    @lexer = lexer
    @current_token = nil
    @peek_token = nil

    consume_token
    consume_token

    @prefix_fns = {
      TokenType::IDENT => parse_identifier,
      TokenType::INT => parse_integer_literal,
    }
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
      prefix_fn = @prefix_fns[@current_token.type]

      throw NoParseFunctionError.new(
        `parser has no function to parse token type #{@current_token.type}`
      ) if prefix_fn.nil?

      left = prefix_fn

      left
    end

    def parse_identifier
      Identifier.new(@current_token, @current_token.literal)
    end

    def parse_integer_literal
      IntegerLiteral.new(@current_token, @current_token.literal.to_i)
    end
end