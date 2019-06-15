require_relative 'ir'

module MyRegexp
  class Node
    def compile
      raise NotImplementationError
    end
  end

  class Char < Node
    attr_reader :char
    def initialize(c)
      @char = c
    end

    def inspect
      char
    end

    def compile
      [
        Ir.char(char)
      ]
    end
  end

  class List < Node
    attr_reader :car, :cdr
    def initialize(car, cdr)
      @car = car
      @cdr = cdr
    end

    def inspect
      inspect_helper(0)
    end

    def inspect_helper(lv = 0)
      base = case car
             when List
               "#{car.inspect_helper(lv + 1)} #{cdr.inspect}"
             else
               "[#{car.inspect} #{cdr.inspect}"
             end
      base + (lv.zero? ? ']' : '')
    end

    def compile
      car.compile + cdr.compile
    end
  end

  class Branch < Node
    attr_reader :left, :right
    def initialize(left, right)
      @left = left
      @right = right
    end

    def inspect
      "(B #{left.inspect} #{right.inspect})"
    end

    def compile
      left_ir = left.compile
      right_ir = right.compile
      [
        Ir.push(left_ir.size + 1),
        *left_ir,
        Ir.jump(right_ir.size),
        *right_ir
      ]
    end
  end

  class Star < Node
    attr_reader :exp
    def initialize(exp)
      @exp = exp
    end

    def inspect
      "(* #{exp.inspect})"
    end

    def compile
      exp_ir = exp.compile
      [
        Ir.push(exp_ir.size + 1),
        *exp_ir,
        Ir.jump(-(exp_ir.size + 2))
      ]
    end
  end

  class Plus < Node
    attr_reader :exp
    def initialize(exp)
      @exp = exp
    end

    def inspect
      "(+ #{exp.inspect})"
    end

    def compile
      exp_ir = exp.compile
      [
        *exp_ir,
        Ir.push(1),
        Ir.jump(-(exp_ir.size + 2))
      ]
    end
  end

  class Option < Node
    attr_reader :exp
    def initialize(exp)
      @exp = exp
    end

    def inspect
      "(? #{exp.inspect})"
    end

    def compile
      exp_ir = exp.compile
      [
        Ir.push(exp_ir.size),
        *exp_ir
      ]
    end
  end

  class Bol < Node
    def inspect
      "^"
    end

    def compile
      [Ir.bol]
    end
  end

  class Eol < Node
    def inspect
      "$"
    end

    def compile
      [Ir.eol]
    end
  end
end
