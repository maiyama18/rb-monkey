require 'spec_helper'

RSpec.describe "Token#new" do
  [
    [RMonkey::TokenType::IDENT, 'foo'],
    [RMonkey::TokenType::ASSIGN, '='],
  ].each do |type, literal|
    it("should initialize token with type #{type} and literal #{literal}") do
      token = RMonkey::Token.new(type, literal)
      expect(token.type).to eq type
      expect(token.literal).to eq literal
    end
  end

  [
    ["INVALID_TOKEN_TYPE", 'invalid'],
    ["", 'invalid'],
  ].each do |type, literal|
    it("should raise Exception for invalid token type #{type}") do
      expect {
        RMonkey::Token.new(type, literal)
      }.to raise_error RMonkey::LexError
    end
  end
end
