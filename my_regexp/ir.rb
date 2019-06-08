module MyRegexp
  class Ir
    OP_CHAR = 0
    OP_PUSH = 1
    OP_JUMP = 2
    OP_MATCH = 3

    # for debug
    OP_NAME = [
      :char,
      :push,
      :jump,
      :match
    ]

    attr_reader :op, :arg1

    def initialize(op, arg1)
      @op = op
      @arg1 = arg1
    end

    def inspect
      [OP_NAME[op], arg1].inspect
    end

    class << self
      def char(char)
        Ir.new(Ir::OP_CHAR, char)
      end

      def push(addr)
        Ir.new(Ir::OP_PUSH, addr)
      end

      def jump(addr)
        Ir.new(Ir::OP_JUMP, addr)
      end

      def match
        Ir.new(Ir::OP_MATCH, nil)
      end

      def compile(ast)
        ast.compile + [Ir.match]
      end
    end
  end
end
