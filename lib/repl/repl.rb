require_relative '../../lib/parser/parser'
require_relative '../../lib/lexer/lexer'
require_relative '../../lib/token/token'

module RMonkey
  class Repl
    PROMPT = '-> '

    def start
      loop do
        print PROMPT
        input = gets

        lexer = Lexer.new(input)
        parser = Parser.new(lexer)
        program = parser.parse_program

        puts program.to_s
      end
    end
  end
end
