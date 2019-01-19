require 'spec_helper'

def parse_program(input)
  lexer = RMonkey::Lexer.new(input)
  parser = RMonkey::Parser.new(lexer)
  parser.parse_program
end

def assert_literal_expression(actual_token, expected)
  case expected
  when String
    expect(actual_token.name).to eq expected
  when Integer, TrueClass, FalseClass
    expect(actual_token.value).to eq expected
  when nil
    expect(actual_token).to be nil
  else
    raise 'unknown class in assert_literal_expression'
  end
end

RSpec.describe "RMonkey::Parser#parse_program" do
  [
    ["let x = 5;", "x", 5],
    ["let foo = true;", "foo", true],
  ].each do |input, expected_name, expected_value|
    it("should parse let statement #{input}") do
      program = parse_program(input)
      expect(program.statements.length).to eq 1
      expect(program.statements[0]).to be_an_instance_of RMonkey::LetStatement

      let_statement = program.statements[0]
      expect(let_statement.identifier.name).to eq expected_name
      expect(let_statement.expression.value).to eq expected_value
    end
  end

  [
    ["return true;", true],
    ["return x;", "x"],
  ].each do |input, expected_value|
    it("should parse return statement #{input}") do
      program = parse_program(input)
      expect(program.statements.length).to eq 1
      expect(program.statements[0]).to be_an_instance_of RMonkey::ReturnStatement

      return_statement = program.statements[0]
      assert_literal_expression(return_statement.expression, expected_value)
    end
  end

  [
    ["42;", 42],
    ["false;", false],
    ["x;", "x"],
  ].each do |input, expected_value|
    it("should parse expression statement #{input}") do
      program = parse_program(input)
      expect(program.statements.length).to eq 1
      expect(program.statements[0]).to be_an_instance_of RMonkey::ExpressionStatement

      expression_statement = program.statements[0]
      assert_literal_expression(expression_statement.expression, expected_value)
    end
  end

  [
    ["-42;", "-", 42],
    ["!true;", "!", true],
  ].each do |input, expected_operator, expected_right|
    it("should parse prefix expression #{input}") do
      program = parse_program(input)
      expect(program.statements.length).to eq 1
      expect(program.statements[0]).to be_an_instance_of RMonkey::ExpressionStatement
      expect(program.statements[0].expression).to be_an_instance_of RMonkey::PrefixExpression

      prefix_expression = program.statements[0].expression
      expect(prefix_expression.operator).to eq expected_operator
      assert_literal_expression(prefix_expression.right, expected_right)
    end
  end

  [
    ["1 + 2;", "+", 1, 2],
    ["1 - 2;", "-", 1, 2],
    ["1 * 2;", "*", 1, 2],
    ["1 / 2;", "/", 1, 2],
    ["1 == 2;", "==", 1, 2],
    ["1 != 2;", "!=", 1, 2],
    ["1 > 2;", ">", 1, 2],
    ["1 < 2;", "<", 1, 2],
    ["true == true", "==", true, true],
    ["true != false", "!=", true, false],
  ].each do |input, expected_operator, expected_left, expected_right|
    it("should parse infix expression #{input}") do
      program = parse_program(input)
      expect(program.statements.length).to eq 1
      expect(program.statements[0]).to be_an_instance_of RMonkey::ExpressionStatement
      expect(program.statements[0].expression).to be_an_instance_of RMonkey::InfixExpression

      infix_expression = program.statements[0].expression
      expect(infix_expression.operator).to eq expected_operator
      assert_literal_expression(infix_expression.left, expected_left)
      assert_literal_expression(infix_expression.right, expected_right)
    end
  end

  [
    ["-a * b", "((-a) * b)"],
    ["-a * b", "((-a) * b)"],
    ["a + b + c", "((a + b) + c)"],
    ["a * b + c", "((a * b) + c)"],
    ["a + b * c", "(a + (b * c))"],
    ["!false", "(!false)"],
    ["!!true", "(!(!true))"],
    ["(a + b) + c", "((a + b) + c)"],
    ["(a + b) * c", "((a + b) * c)"],
    ["a + (b + c)", "(a + (b + c))"],
    ["a * (b + c) / d", "((a * (b + c)) / d)"],
    ["!(true == true)", "(!(true == true))"],
  ].each do |input, expected|
    it("should parse expression #{input} with correct precedence") do
      program = parse_program(input)
      expect(program.statements.length).to eq 1
      expect(program.statements[0].to_s).to eq expected
    end
  end

  [
    ["if (a) { b; }", "a", "b", nil],
    ["if (a) { b; } else { c; }", "a", "b", "c"],
  ].each do |input, expected_condition, expected_consequence, expected_alternative|
    it("should parse if expression #{input}") do
      program = parse_program(input)
      expect(program.statements.length).to eq 1
      expect(program.statements[0]).to be_an_instance_of RMonkey::ExpressionStatement
      expect(program.statements[0].expression).to be_an_instance_of RMonkey::IfExpression

      if_expression = program.statements[0].expression
      assert_literal_expression(if_expression.condition, expected_condition)
      assert_literal_expression(if_expression.consequence.statements[0].expression, expected_consequence)
      if expected_alternative.nil?
        assert_literal_expression(if_expression.alternative, expected_alternative)
      else
        assert_literal_expression(if_expression.alternative.statements[0].expression, expected_alternative)
      end
    end
  end

  [
    ["fn() { 1; }", [], 1],
    ["fn(x) { x; }", ["x"], "x"],
    ["fn(x, y) { y; }", ["x", "y"], "y"],
    ["fn(x, y, z) { z; }", ["x", "y", "z"], "z"],
  ].each do |input, expected_parameters, expected_value|
    it("should parse function literal #{input}") do
      program = parse_program(input)
      expect(program.statements.length).to eq 1
      expect(program.statements[0]).to be_an_instance_of RMonkey::ExpressionStatement
      expect(program.statements[0].expression).to be_an_instance_of RMonkey::FunctionLiteral

      function_literal = program.statements[0].expression
      expect(function_literal.parameters.map(&:name)).to eq expected_parameters
      assert_literal_expression(function_literal.body.statements[0].expression, expected_value)
    end
  end
  
  [
    ["one()", "one", []],
    ["identity(a)", "identity", ["a"]],
    ["add(2, 3)", "add", [2, 3]],
  ].each do |input, expected_name, expected_arguments|
    it("should parse call expression #{input}") do
      program = parse_program(input)
      expect(program.statements.length).to eq 1
      expect(program.statements[0]).to be_an_instance_of RMonkey::ExpressionStatement
      expect(program.statements[0].expression).to be_an_instance_of RMonkey::CallExpression

      call_expression = program.statements[0].expression
      expect(call_expression.function.name).to eq expected_name
      expected_arguments.each_with_index do |expected_argument, i|
        assert_literal_expression(call_expression.arguments[i], expected_argument)
      end
    end
  end

  [
    ["fn() { 1; }()", 1, []],
    ["fn(x) { x; }(42)", "x", [42]],
  ].each do |input, expected_return_value, expected_arguments|
    it("should parse immediate function call expression #{input}") do
      program = parse_program(input)
      expect(program.statements.length).to eq 1
      expect(program.statements[0]).to be_an_instance_of RMonkey::ExpressionStatement
      expect(program.statements[0].expression).to be_an_instance_of RMonkey::CallExpression

      call_expression = program.statements[0].expression
      assert_literal_expression(call_expression.function.body.statements[0].expression, expected_return_value)
      expected_arguments.each_with_index do |expected_argument, i|
        assert_literal_expression(call_expression.arguments[i], expected_argument)
      end
    end
  end

  [
    "let x 5;",
    "if (x);",
  ].each do |input|
    it("should raise ParseError for input #{input}") do
      expect {
        parse_program(input)
      }.to raise_error(RMonkey::ParseError)
    end
  end
end
