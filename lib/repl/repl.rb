require_relative '../evaluator/evaluator'
require_relative '../parser/parser'
require_relative '../parser/parser'
require_relative '../lexer/lexer'
require_relative '../token/token'

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

        puts Evaluator.eval(program).to_s
      end
    end
  end
end
