require_relative './spec_helper'

def eval_program(input)
  lexer = Lexer.new(input)
  parser = Parser.new(lexer)
  program = parser.parse_program

  Evaluator.eval(program)
end

RSpec.describe "eval integer operation" do
  [
    ['42', 42],
    ['-5', -5],
    ['-(-5)', 5],
    ['1 + 2', 3],
    ['1 + 2 * 3', 7],
    ['(1 + 2) * 3', 9],
    ['1 + 2 * 3 + 4', 11],
  ].each do |input, expected|
    it("should eval #{input} to be #{expected}") do
      expect(test_eval_program(input)).to eq expected
    end
  end
end
