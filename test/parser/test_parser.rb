require 'minitest/autorun'
require_relative '../../lib/parser/parser'

class ParserTest < Minitest::Test
  # @return [Programt]
  def parse_program(input)
    lexer = Lexer.new(input)
    parser = Parser.new(lexer)
    parser.parse_program
  end

  def test_parse_let_statement
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

  def test_parse_return_statement
    input = 'return x;'
    program = parse_program(input)

    assert_equal 1, program.statements.length
    assert_instance_of ReturnStatement, program.statements[0]
  end

  def test_parse_identifier_expression
    input = 'foo;'
    program = parse_program(input)

    assert_equal 1, program.statements.length
    assert_instance_of ExpressionStatement, program.statements[0]

    assert_instance_of Identifier, program.statements[0].expression
    assert_equal 'foo', program.statements[0].expression.name
  end

  def test_parse_integer_literal_expression
    input = '42;'
    program = parse_program(input)

    assert_equal 1, program.statements.length
    assert_instance_of ExpressionStatement, program.statements[0]

    assert_instance_of IntegerLiteral, program.statements[0].expression
    assert_equal 42, program.statements[0].expression.value
  end

  def test_parse_prefix_expression
    input = <<~INPUT
      -42;
      !42;
    INPUT
    program = parse_program(input)

    assert_equal 2, program.statements.length

    assert_instance_of ExpressionStatement, program.statements[0]
    test_prefix_expression('-', 42, program.statements[0].expression)

    assert_instance_of ExpressionStatement, program.statements[1]
    test_prefix_expression('!', 42, program.statements[1].expression)
  end

  def test_parse_infix_expression
    input = <<~INPUT
      1 + 2;
      3 - 4;
      5 * 6;
      7 / 8;
      9 == 10;
      11 != 12;
      13 > 14;
      15 < 16;
    INPUT
    program = parse_program(input)

    assert_equal 8, program.statements.length

    program.statements.each do |statement|
      assert_instance_of ExpressionStatement, statement
    end

    test_infix_expression(1, '+', 2, program.statements[0].expression)
    test_infix_expression(3, '-', 4, program.statements[1].expression)
    test_infix_expression(5, '*', 6, program.statements[2].expression)
    test_infix_expression(7, '/', 8, program.statements[3].expression)
    test_infix_expression(9, '==', 10, program.statements[4].expression)
    test_infix_expression(11, '!=', 12, program.statements[5].expression)
    test_infix_expression(13, '>', 14, program.statements[6].expression)
    test_infix_expression(15, '<', 16, program.statements[7].expression)
  end

  def test_parse_infix_with_precedence
    input = <<~INPUT
      -a * b;
      !-a
      a + b + c
      a * b + c
      a + b * c
    INPUT
    program = parse_program(input)

    assert_equal 5, program.statements.length

    assert_equal '((-a) * b)', program.statements[0].to_s
    assert_equal '(!(-a))', program.statements[1].to_s
    assert_equal '((a + b) + c)', program.statements[2].to_s
    assert_equal '((a * b) + c)', program.statements[3].to_s
    assert_equal '(a + (b * c))', program.statements[4].to_s
  end

  def test_parse_error
    input = 'let x 5;'

    err = assert_raises ParseError do
      parse_program(input)
    end

    assert err.message.include?('expect token type')
  end

  private

  def test_prefix_expression(operator, right_value, actual)
    assert_instance_of PrefixExpression, actual
    assert_equal operator, actual.operator
    assert_equal right_value, actual.right.value
  end

  def test_infix_expression(left_value, operator, right_value, actual)
    assert_instance_of InfixExpression, actual
    assert_equal left_value, actual.left.value
    assert_equal operator, actual.operator
    assert_equal right_value, actual.right.value
  end
end
