require 'spec_helper'

def eval_program(input)
  lexer = RMonkey::Lexer.new(input)
  parser = RMonkey::Parser.new(lexer)
  program = parser.parse_program

  RMonkey::Evaluator.eval(program)
end

RSpec.describe "Evaluator::eval" do
  [
    ['42', 42],
    ['-5', -5],
    ['-(-5)', 5],
    ['1 + 2', 3],
    ['1 + 2 * 3', 7],
    ['(1 + 2) * 3', 9],
    ['1 + 2 * 3 + 4', 11],
  ].each do |input, expected|
    it("should eval integer operation #{input}") do
      expect(eval_program(input).value).to eq expected
    end
  end

  [
    ['true', true],
    ['false', false],
    ['!true', false],
    ['!false', true],
    ['!5', false],
    ['!!true', true],
    ['!!false', false],
    ['!!5', true],
    ['3 == 3', true],
    ['3 == 4', false],
    ['3 != 3', false],
    ['3 != 4', true],
    ['4 > 3', true],
    ['3 > 3', false],
    ['3 < 4', true],
    ['3 > 3', false],
    ['true == true', true],
    ['true == false', false],
    ['true != true', false],
    ['true != false', true],
  ].each do |input, expected|
    it("should eval boolean operation #{input}") do
      expect(eval_program(input).value).to eq expected
    end
  end
end
