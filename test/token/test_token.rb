require 'minitest/autorun'
require_relative '../../src/token/token_type'
require_relative '../../src/token/token'

class TokenTest < Minitest::Test
  def test_token_initialization
    token = Token.new(TokenType::IDENT, 'foo')

    assert_equal TokenType::IDENT, token.type
    assert_equal 'foo', token.literal
  end

  def test_invalid_token_initialization
    err = assert_raises RuntimeError do
      Token.new('INVALID_TOKEN_TYPE', 'invalid')
    end

    assert err.message.include?('invalid token type')
  end
end