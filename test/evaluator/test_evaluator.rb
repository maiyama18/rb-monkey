require 'minitest/autorun'
require_relative '../../lib/evaluator/evaluator'

module RMonkey
  class EvaluatorTest < Minitest::Test
    def test_eval_integer_literal
      input = '42;'
      evaluated = eval_program(input)

      assert_equal 42, evaluated.value
    end

    def test_eval_boolean_literal
      input = 'true;'
      evaluated = eval_program(input)

      assert_equal true, evaluated.value
    end

    def eval_program(input)
      lexer = Lexer.new(input)
      parser = Parser.new(lexer)
      program = parser.parse_program

      Evaluator.eval(program)
    end
  end
end