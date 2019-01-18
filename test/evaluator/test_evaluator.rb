require 'minitest/autorun'
require_relative '../../lib/evaluator/evaluator'

module RMonkey
  class EvaluatorTest < Minitest::Test
    def test_eval_integer
      test_cases = [
        {input: '42', expected: 42},
        {input: '-5', expected: -5},
        {input: '-(-5)', expected: 5},
        {input: '4 + 2', expected: 6},
        {input: '4 - 2', expected: 2},
        {input: '4 * 2', expected: 8},
        {input: '4 / 2', expected: 2},
      ]

      test_cases.each do |test_case|
        evaluated = eval_program(test_case[:input])
        assert_equal test_case[:expected], evaluated.value
      end
    end

    def test_eval_boolean
      input = 'true;'
      test_cases = [
        {input: 'true', expected: true},
        {input: 'false', expected: false},
        {input: '!true', expected: false},
        {input: '!false', expected: true},
        {input: '!5', expected: false},
        {input: '!!true', expected: true},
        {input: '!!false', expected: false},
        {input: '!!5', expected: true},
        {input: '3 == 3', expected: true},
        {input: '3 == 4', expected: false},
        {input: '3 != 3', expected: false},
        {input: '3 != 4', expected: true},
        {input: '4 > 3', expected: true},
        {input: '3 > 3', expected: false},
        {input: '3 < 4', expected: true},
        {input: '3 > 3', expected: false},
        {input: 'true == true', expected: true},
        {input: 'true == false', expected: false},
        {input: 'true != true', expected: false},
        {input: 'true != false', expected: true},
      ]
      evaluated = eval_program(input)

      test_cases.each do |test_case|
        evaluated = eval_program(test_case[:input])
        assert_equal test_case[:expected], evaluated.value
      end
    end

    def eval_program(input)
      lexer = Lexer.new(input)
      parser = Parser.new(lexer)
      program = parser.parse_program

      Evaluator.eval(program)
    end
  end
end