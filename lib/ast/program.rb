class Program
  attr_accessor :token, :statements

  def initialize(statements)
    @token = statements.length.zero? ? Token.new(TokenType::EOF, '') : statements[0].token
    @statements = statements
  end
end