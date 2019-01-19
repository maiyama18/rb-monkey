module RMonkey
  class Environment
    attr_accessor :hash, :outer

    def initialize(outer = nil)
      @hash = {}
      @outer = outer
    end

    def get(name)
      return hash[name] if hash.has_key? name

      if outer.nil?
        raise EvalError.new 'undefined variable'
      else
        outer.get(name)
      end
    end

    def set(name, value)
      hash[name] = value
    end

    def extend
      Environment.new(self)
    end
  end
end