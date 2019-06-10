module MyRegexp
  class Vm
    VmThread = Struct.new(:pc, :sp)

    attr_reader :ir, :str, :stack
    def initialize(ir)
      @ir = ir
    end

    def match(str)
      # TODO spの位置を変えつつマッチさせて部分一致も実装する
      sp = 0
      match_at(0, sp, str)
    end

    private
    def push(pc, sp)
      stack.push(VmThread.new(pc, sp))
    end

    def pop
      th = stack.pop
      [th.pc, th.sp]
    end

    def init(sp)
      @stack = []
      push(0, sp)
    end

    def match_at(sp, pc, str)
      init(sp)
      until stack.empty?
        pc, sp = pop
        loop do
          code = ir[pc]
          pc += 1

          case code.op
          when Ir::OP_CHAR
            break if code.arg1 != str[sp]

            sp += 1
          when Ir::OP_PUSH
            push(pc + code.arg1, sp)
          when Ir::OP_JUMP
            pc += code.arg1
          when Ir::OP_MATCH
            return true
          end
        end
      end
    end
  end
end
