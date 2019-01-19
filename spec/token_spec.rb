require 'spec_helper'

RSpec.describe "token initialization" do
  [
    [RMonkey::TokenType::IDENT, 'foo'],
    [RMonkey::TokenType::ASSIGN, '='],
  ].each do |type, literal|
    it("should init token with type #{type} and literal #{literal}") do
      token = RMonkey::Token.new(type, literal)
      expect(token.type).to eq type
      expect(token.literal).to eq literal
    end
  end
end

RSpec.describe "invalid token initialization" do
  [
    ["INVALID_TOKEN_TYPE", 'invalid'],
  ].each do |type, literal|
    it("should raise Exception for token with type #{type}") do
      expect {
        RMonkey::Token.new(type, literal)
      }.to raise_error RMonkey::InvalidTokenError
    end
  end
end
