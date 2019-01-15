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
      true == true
      true != false
    INPUT
    program = parse_program(input)

    assert_equal 10, program.statements.length

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
    test_infix_expression(true, '==', true, program.statements[8].expression)
    test_infix_expression(true, '!=', false, program.statements[9].expression)
  end

  def test_parse_infix_with_precedence
    input = <<~INPUT
      -a * b;
      !-a
      a + b + c
      a * b + c
      a + b * c
      !false
      !!true
    INPUT
    program = parse_program(input)

    assert_equal 7, program.statements.length

    assert_equal '((-a) * b)', program.statements[0].to_s
    assert_equal '(!(-a))', program.statements[1].to_s
    assert_equal '((a + b) + c)', program.statements[2].to_s
    assert_equal '((a * b) + c)', program.statements[3].to_s
    assert_equal '(a + (b * c))', program.statements[4].to_s
    assert_equal '(!false)', program.statements[5].to_s
    assert_equal '(!(!true))', program.statements[6].to_s
  end

  def test_parse_grouped_infix_with_precedence
    input = <<~INPUT
      (a + b) + c;
      (a + b) * c;
      a + (b + c);
      a + (b * c);
      a * (b + c) / d;
      !(true == true);
    INPUT
    program = parse_program(input)

    assert_equal 6, program.statements.length

    assert_equal '((a + b) + c)', program.statements[0].to_s
    assert_equal '((a + b) * c)', program.statements[1].to_s
    assert_equal '(a + (b + c))', program.statements[2].to_s
    assert_equal '(a + (b * c))', program.statements[3].to_s
    assert_equal '((a * (b + c)) / d)', program.statements[4].to_s
    assert_equal '(!(true == true))', program.statements[5].to_s
  end

  def test_parse_if_expression
    input = 'if (a > b) { c }'
    program = parse_program(input)

    assert_equal 1, program.statements.length

    assert_instance_of ExpressionStatement, program.statements[0]
    assert_instance_of IfExpression, program.statements[0].expression

    exp = program.statements[0].expression
    test_infix_expression('a', '>', 'b', exp.condition)

    assert_instance_of BlockStatement, exp.consequence
    assert_equal 1, exp.consequence.statements.length
    assert_instance_of ExpressionStatement, exp.consequence.statements[0]
    assert_instance_of Identifier, exp.consequence.statements[0].expression
    test_literal_expression 'c', exp.consequence.statements[0].expression
  end

  def test_parse_if_expression
    input = 'if (true) { 10 } else { 5 + 6 }'
    program = parse_program(input)

    assert_equal 1, program.statements.length

    assert_instance_of ExpressionStatement, program.statements[0]
    assert_instance_of IfExpression, program.statements[0].expression

    exp = program.statements[0].expression
    test_literal_expression(true, exp.condition)

    assert_instance_of BlockStatement, exp.consequence
    assert_equal 1, exp.consequence.statements.length
    assert_instance_of ExpressionStatement, exp.consequence.statements[0]
    assert_instance_of IntegerLiteral, exp.consequence.statements[0].expression
    test_literal_expression 10, exp.consequence.statements[0].expression

    assert_instance_of BlockStatement, exp.alternative
    assert_equal 1, exp.alternative.statements.length
    assert_instance_of ExpressionStatement, exp.alternative.statements[0]
    assert_instance_of InfixExpression, exp.alternative.statements[0].expression
    test_infix_expression(5, '+', 6, exp.alternative.statements[0].expression)
  end

  def test_parse_error
    input = 'let x 5;'

    err = assert_raises ParseError do
      parse_program(input)
    end

    assert err.message.include?('expect token type')
  end

  private

  def test_prefix_expression(operator, expected_right, expression)
    assert_instance_of PrefixExpression, expression
    assert_equal operator, expression.operator
    test_literal_expression(expected_right, expression.right)
  end

  def test_infix_expression(expected_left, operator, expected_right, expression)
    assert_instance_of InfixExpression, expression
    test_literal_expression(expected_left, expression.left)
    assert_equal operator, expression.operator
    test_literal_expression(expected_right, expression.right)
  end

  def test_literal_expression(expected, expression)
    case expected
    when Integer
      assert_equal expected, expression.value
    when String
      assert_equal expected, expression.name
    when TrueClass, FalseClass
      assert_equal expected, expression.value
    else
      raise 'unknown class in test_literal_expression'
    end
  end
end
