require_relative '../lexer/lexer'
require_relative '../ast/expression'
require_relative '../ast/statement'
require_relative '../ast/program'
require_relative '../error/error'

module RMonkey
  module Precedence
    LOWEST = 0
    EQUAL = 1
    COMPARISON = 2
    SUM = 3
    PRODUCT = 4
    PREFIX = 5
    CALL = 6

    # @param [TokenType] token_type
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
      when TokenType::LPAREN
        CALL
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

    # @param [TokenType] type
    def expect_peek(type)
      raise ParseError.new "expect token type #{type}, but got token #{@peek_token}" if type != @peek_token.type

      consume_token
    end

    def peek_precedence
      Precedence.from(@peek_token.type)
    end

    def parse_block_statement
      token = @current_token
      consume_token

      statements = []
      until @current_token.type == TokenType::RBRACE
        statements << parse_statement
        consume_token
      end
      BlockStatement.new(token, statements)
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
      consume_token
      expression = parse_expression(Precedence::LOWEST)

      consume_token if @peek_token.type == TokenType::SEMICOLON
      LetStatement.new(token, identifier, expression)
    end

    def parse_return_statement
      token = @current_token

      consume_token
      expression = parse_expression(Precedence::LOWEST)

      consume_token if @peek_token.type == TokenType::SEMICOLON
      ReturnStatement.new(token, expression)
    end

    def parse_expression_statement
      token = @current_token

      expression = parse_expression(Precedence::LOWEST)

      consume_token if @peek_token.type == TokenType::SEMICOLON
      ExpressionStatement.new(token, expression)
    end

    # @param [Precedence] precedence
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
             when TokenType::IF
               parse_if_expression
             when TokenType::FN
               parse_function_literal
             else
               raise ParseError.new "parser has no function to parse prefix token type #{@current_token.type}"
             end

      while precedence < peek_precedence
        consume_token
        left = case @current_token.type
               when TokenType::EQ, TokenType::NEQ, TokenType::GT, TokenType::LT, TokenType::PLUS, TokenType::MINUS, TokenType::ASTERISK, TokenType::SLASH
                 parse_infix_expression(left)
               when TokenType::LPAREN
                 parse_call_expression(left)
               else
                 raise ParseError.new "parser has no function to parse infix token type #{@current_token.type}"
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

    # @param [Expression] left
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

    def parse_if_expression
      token = @current_token

      expect_peek(TokenType::LPAREN)
      consume_token
      condition = parse_expression(Precedence::LOWEST)
      expect_peek(TokenType::RPAREN)

      expect_peek(TokenType::LBRACE)
      consequence = parse_block_statement

      return IfExpression.new(token, condition, consequence, nil) unless @peek_token.type == TokenType::ELSE

      expect_peek(TokenType::ELSE)
      expect_peek(TokenType::LBRACE)
      alternative = parse_block_statement

      consume_token if @peek_token.type == TokenType::SEMICOLON

      IfExpression.new(token, condition, consequence, alternative)
    end

    def parse_function_literal
      token = @current_token

      expect_peek(TokenType::LPAREN)
      parameters = parse_expressions_in_parens

      expect_peek(TokenType::LBRACE)
      body = parse_block_statement

      consume_token if @peek_token.type == TokenType::SEMICOLON

      FunctionLiteral.new(token, parameters, body)
    end

    def parse_call_expression(left)
      token = left.token

      function = left

      arguments = parse_expressions_in_parens

      CallExpression.new(token, function, arguments)
    end

    def parse_expressions_in_parens
      consume_token

      return [] if @current_token.type == TokenType::RPAREN

      identifiers = [parse_expression(Precedence::LOWEST)]
      while @peek_token.type == TokenType::COMMA
        consume_token
        consume_token
        identifiers << parse_expression(Precedence::LOWEST)
      end

      expect_peek(TokenType::RPAREN)

      identifiers
    end
  end
end
