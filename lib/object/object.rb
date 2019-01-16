module RMonkey
  module ObjectType
    INTEGER = 'INTEGER'
    BOOLEAN = 'BOOLEAN'
    NULL = 'NULL'
  end

  class Object
    attr_accessor :type

    def to_s
      raise 'should be overridden in subclasses'
    end
  end

  class Integer
    attr_accessor :value

    def initialize(value)
      @type = ObjectType::INTEGER
      @value = value
    end

    def to_s
      value.to_s
    end
  end

  class Boolean
    attr_accessor :value

    def initialize(value)
      @type = ObjectType::BOOLEAN
      @value = value
    end

    def to_s
      value.to_s
    end
  end

  class Null
    def initialize
      @type = ObjectType::NULL
    end

    def to_s
      "null"
    end
  end
end