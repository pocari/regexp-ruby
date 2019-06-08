module MyRegexp
  class Vm
    VmThread = Struct.new(:ip, :sp)

    attr_reader :ir, :str, :stack
    def initialize(ir)
      @ir = ir
      @stack = []
    end

    def match(str)
      sp = 0
      match_at(0, sp, str)
    end

    private
    def push(ip, sp)
      stack.push(VmThread.new(ip, sp))
    end

    def pop
      th = stack.pop
      [th.ip, th.sp]
    end

    def init(sp)
      @stack = []
      push(0, sp)
    end

    def match_at(sp, ip, str)
      init(sp)
      until stack.empty?
        ip, sp = pop
        loop do
          code = ir[ip]
          ip += 1

          case code.op
          when Ir::OP_CHAR
            break if code.arg1 != str[sp]

            sp += 1
          when Ir::OP_PUSH
            push(ip + code.arg1, sp)
          when Ir::OP_JUMP
            ip += code.arg1
          when Ir::OP_MATCH
            return true
          end
        end
      end
    end
  end
end
