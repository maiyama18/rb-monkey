require 'minitest/autorun'
require_relative '../../lib/parser/parser'

class ParserTest < Minitest::Test
  def test_let_statement
    input = <<~INPUT
    let x = 5;
    let foo = 42;
    INPUT

    lexer = Lexer.new(input)
    parser = Parser.new(lexer)
    program = parser.parse_program

    assert_equal 2, program.statements.length

    assert_instance_of LetStatement, program.statements[0]
    assert_equal 'x', program.statements[0].identifier.name

    assert_instance_of LetStatement, program.statements[0]
    assert_equal 'foo', program.statements[1].identifier.name
  end

  def test_return_statement
    input = 'return x;'

    lexer = Lexer.new(input)
    parser = Parser.new(lexer)
    program = parser.parse_program

    assert_equal 1, program.statements.length

    assert_instance_of ReturnStatement, program.statements[0]
  end

  def test_parse_error
    input = 'let x 5;'

    lexer = Lexer.new(input)
    parser = Parser.new(lexer)

    err = assert_raises ParseError do
      parser.parse_program
    end

    assert err.message.include?('expect token type')
  end
end
