require_relative '../../src/lexer/lexer'
require_relative '../../src/token/token'

class Repl
  PROMPT = '-> '

  def start
    loop do
      print PROMPT
      input = gets

      lexer = Lexer.new(input)
      token = lexer.next_token
      until token.type == TokenType::EOF
        puts token
        token = lexer.next_token
      end
    end
  end
end