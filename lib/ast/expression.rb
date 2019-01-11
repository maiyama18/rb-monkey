class Expression
  attr_accessor :token
end

class Identifier < Expression
  attr_accessor :name

  # @param [Token] token
  # @param [String] name
  def initialize(token, name)
    @token = token
    @name = name
  end
end