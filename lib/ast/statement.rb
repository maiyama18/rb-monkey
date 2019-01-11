class Statement
  attr_accessor :token
end

class LetStatement < Statement
  attr_accessor :identifier, :expression

  def initialize(token, identifier, expression)
    @token = token
    @identifier = identifier
    @expression = expression
  end
end