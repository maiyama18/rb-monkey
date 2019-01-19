module RMonkey
  class Environment
    attr_accessor :hash

    def initialize
      @hash = Hash.new { raise EvalError.new 'undefined variable' }
    end

    def get(name)
      @hash[name]
    end

    def set(name, value)
      @hash[name] = value
    end
  end
end