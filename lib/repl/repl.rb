require_relative '../evaluator/evaluator'
require_relative '../parser/parser'
require_relative '../parser/parser'
require_relative '../lexer/lexer'
require_relative '../token/token'
require_relative '../object/environment'

module RMonkey
  class Repl
    PROMPT = '-> '

    def start
      env = RMonkey::Environment.new

      loop do
        print PROMPT
        input = gets

        begin
          lexer = Lexer.new(input)
          parser = Parser.new(lexer)
          program = parser.parse_program
        rescue RMonkey::ParseError, RMonkey::LexError => e
          puts "#{e.class}: #{e.message}"
          redo
        end

        begin
          evaluated = Evaluator.eval(program, env).to_s
          puts evaluated
        rescue RMonkey::EvalError => e
          puts "#{e.class}: #{e.message}"
          redo
        end
      end
    end
  end
end
