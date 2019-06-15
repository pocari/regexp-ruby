module MyRegexp
  class Vm
    VmThread = Struct.new(:pc, :sp)

    attr_reader :ir, :str, :stack
    def initialize(ir)
      @ir = ir
    end

    def match(str)
      sp = 0
      str.length.times do |sp|
        return true if match_at(sp, 0, str)
      end
      nil
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
          when Ir::OP_BOL
            break if sp != 0
          when Ir::OP_EOL
            break if sp != str.length
          when Ir::OP_MATCH
            return true
          end
        end
      end
    end
  end
end
