require 'minitest/autorun'
require_relative '../../lib/parser/parser'

class ParserTest < Minitest::Test
  # @return [Programt]
  def parse_program(input)
    lexer = Lexer.new(input)
    parser = Parser.new(lexer)
    parser.parse_program
  end

  def test_let_statement
    input = <<~INPUT
    let x = 5;
    let foo = 42;
    INPUT
    program = parse_program(input)

    assert_equal 2, program.statements.length

    assert_instance_of LetStatement, program.statements[0]
    assert_equal 'x', program.statements[0].identifier.name

    assert_instance_of LetStatement, program.statements[1]
    assert_equal 'foo', program.statements[1].identifier.name
  end

  def test_return_statement
    input = 'return x;'
    program = parse_program(input)

    assert_equal 1, program.statements.length
    assert_instance_of ReturnStatement, program.statements[0]
  end

  def test_identifier_expression
    input = 'foo;'
    program = parse_program(input)

    assert_equal 1, program.statements.length
    assert_instance_of ExpressionStatement, program.statements[0]

    assert_instance_of Identifier, program.statements[0].expression
    assert_equal 'foo', program.statements[0].expression.name
  end

  def test_integer_literal_expression
    input = '42;'
    program = parse_program(input)

    assert_equal 1, program.statements.length
    assert_instance_of ExpressionStatement, program.statements[0]

    assert_instance_of IntegerLiteral, program.statements[0].expression
    assert_equal 42, program.statements[0].expression.value
  end

  def test_minus_expression
    input = '-42;'
    program = parse_program(input)

    assert_equal 1, program.statements.length
    assert_instance_of ExpressionStatement, program.statements[0]

    exp = program.statements[0].expression
    assert_instance_of PrefixExpression, exp
    assert_equal '-', exp.operator
    assert_equal 42, exp.right.value
  end

  def test_bang_expression
    input = '!42;'
    program = parse_program(input)

    assert_equal 1, program.statements.length
    assert_instance_of ExpressionStatement, program.statements[0]

    exp = program.statements[0].expression
    assert_instance_of PrefixExpression, exp
    assert_equal '!', exp.operator
    assert_equal 42, exp.right.value
  end

  def test_parse_error
    input = 'let x 5;'

    err = assert_raises ParseError do
      parse_program(input)
    end

    assert err.message.include?('expect token type')
  end
end
