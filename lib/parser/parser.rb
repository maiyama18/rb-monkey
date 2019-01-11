require_relative '../lexer/lexer'
require_relative '../ast/expression'
require_relative '../ast/statement'
require_relative '../ast/program'
require_relative '../error/error'

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

  private def consume_token
    @current_token = @peek_token
    @peek_token = @lexer.next_token

  end

  private def expect_peek(type)
    raise ParseError.new "expect token type #{type}, but got token #{@peek_token}" if type != @peek_token.type

    consume_token
  end

  private def parse_statement
    case @current_token.type
    when TokenType::LET
      parse_let_statement
    else
      raise ParseError.new "unexpected token: #{@current_token}"
    end
  end

  private def parse_let_statement
    token = @current_token

    expect_peek(TokenType::IDENT)
    identifier = Identifier.new(@current_token, @current_token.literal)

    expect_peek(TokenType::ASSIGN)
    until @current_token.type == TokenType::SEMICOLON
      consume_token
    end

    LetStatement.new(token, identifier, nil)
  end
end