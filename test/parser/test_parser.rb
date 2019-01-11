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

    assert_equal 'x', program.statements[0].identifier.name
    assert_equal 'foo', program.statements[1].identifier.name
  end
end
