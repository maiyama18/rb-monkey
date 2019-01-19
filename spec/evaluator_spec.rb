require 'spec_helper'

def eval_program(input)
  lexer = RMonkey::Lexer.new(input)
  parser = RMonkey::Parser.new(lexer)
  program = parser.parse_program
  env = RMonkey::Environment.new

  RMonkey::Evaluator.eval(program, env)
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

  [
    ['if (true) { 10 }', 10],
    ['if (false) { 10 }', nil],
    ['if (false) { 10 } else { 20 }', 20],
    ['if (10) { 10 }', 10],
    ['if (!10) { 10 }', nil],
    ['if (!10) { 10 } else { 20 }', 20],
    ['if (10 > 5) { 10 }', 10],
    ['if (10 < 5) { 10 }', nil],
    ['if (10 < 5) { 10 } else { 20 }', 20],
    ['if (10 == 10) { 10 }', 10],
    ['if (10 != 5) { 10 }', 10],
  ].each do |input, expected|
    it("should eval if expression #{input}") do
      expect(eval_program(input).value).to eq expected
    end
  end

  [
    ['return 10;', 10],
    ['9; return 10;', 10],
    ['return 10; 9;', 10],
    ['if (true) { return 10; } return 9;', 10],
    ['if (false) { return 9; } else { return 10; } return 9;', 10],
    ['if (true) { if (true) { return 10; } return 9; } return 9;', 10],
  ].each do |input, expected|
    it("should eval return statement #{input}") do
      expect(eval_program(input).value).to eq expected
    end
  end

  [
    ["let a = 5; a;", 5],
    ["let a = 5; a + 10;", 15],
    ["let a = 5; a * a;", 25],
    ["let a = 5; let b = a; b;", 5],
    ["let a = 5; let b = a; let c = a * b; c;", 25],
  ].each do |input, expected|
    it("should eval assigned variable with let statement: #{input}") do
      expect(eval_program(input).value).to eq expected
    end
  end

  [
    ["fn() { 1; }", [], "1"],
    ["fn(x, y) { x + y; }", ["x", "y"], "(x + y)"],
  ].each do |input, expected_parameters, expected_body_string|
    it("should eval function literal #{input}") do
      evaluated = eval_program(input)
      expect(evaluated.parameters.map(&:name)).to eq expected_parameters
      expect(evaluated.body.to_s).to eq expected_body_string
    end
  end

  [
    ["let five = fn() { 5; }; five();", 5],
    ["let identity = fn(x) { x; }; identity(5);", 5],
    ["fn(x) { x; }(5);", 5],
    ["let add = fn(x, y) { x + y; }; add(2, 3);", 5],
    ["let add = fn(x, y) { x + y; }; let a = 2; let b = 3; add(a, b);", 5],
    ["let add = fn(x, y) { x + y; }; add(add(1, 1), add(1, 2));", 5],
  ].each do |input, expected|
    it("should eval function call #{input}") do
      expect(eval_program(input).value).to eq expected
    end
  end

  [
    "1 + true",
    "1 == true",
    "-true",
    "true + false",
  ].each do |input|
    it("should raise EvalError for input #{input}: invalid operation") do
      expect {
        eval_program(input)
      }.to raise_error(RMonkey::EvalError)
    end
  end

  [
    "foo;",
    "5 + foo;",
  ].each do |input|
  it("should raise EvalError for input #{input}: undefined variable") do
    expect {
      eval_program(input)
    }.to raise_error(RMonkey::EvalError)
  end
end
end
