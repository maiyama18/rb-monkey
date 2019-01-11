require_relative './node'

class Program < Node
  attr_accessor :token, :statements

  def initialize(statements)
    @token = statements.length.zero? ? Token.new(TokenType::EOF, '') : statements[0].token
    @statements = statements
  end

  def to_s
    @statements.map(&:to_s).join
  end
end