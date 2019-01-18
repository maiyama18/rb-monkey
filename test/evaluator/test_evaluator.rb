require 'minitest/autorun'
require_relative '../../lib/evaluator/evaluator'

module RMonkey
  class EvaluatorTest < Minitest::Test
    def test_eval_integer
      test_cases = [
        {input: '42', expected: 42},
        {input: '-5', expected: -5},
        {input: '-(-5)', expected: 5},
        {input: '1 + 2', expected: 3},
        {input: '1 + 2 * 3', expected: 7},
        {input: '(1 + 2) * 3', expected: 9},
        {input: '1 + 2 * 3 + 4', expected: 11},
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