require 'minitest/autorun'
require_relative '../../lib/token/token'

class TokenTest < Minitest::Test
  def test_token_initialization
    ident_token = Token.new(TokenType::IDENT, 'foo')
    assert_equal TokenType::IDENT, ident_token.type
    assert_equal 'foo', ident_token.literal

    assign_token = Token.new(TokenType::ASSIGN, '=')
    assert_equal TokenType::ASSIGN, assign_token.type
    assert_equal '=', assign_token.literal
  end

  def test_invalid_token_initialization
    err = assert_raises RuntimeError do
      Token.new('INVALID_TOKEN_TYPE', 'invalid')
    end

    assert err.message.include?('invalid token type')
  end
end
