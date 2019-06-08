require 'parslet'

class RegexpParser < Parslet::Parser
  rule(:regexp) {
    (
      list.as(:left) >> (op_branch >> list.as(:right)).repeat
    ).as(:branch)
  }

  rule(:list) {
    (
      (exp >> op_star).as(:star) |
      (exp >> op_plus).as(:plus) |
      exp
    ).repeat(1).as(:list)
  }

  rule(:exp) {
    (
      str('(') >> regexp >> str(')') |
      (str('\\') >> any.as(:escaped)).as(:escaped_char) |
      match(/[^*+|)(]/).as(:char)
    )
  }

  rule(:op_branch) { str('|') }
  rule(:op_star) { str('*') }
  rule(:op_plus) { str('+') }

  root(:regexp)
end

class RegexpTransformer < Parslet::Transform
  rule(char: simple(:x)) { Char.new(x.to_s) }
  rule(escaped: simple(:x)) { Char.new(x.to_s) }
  rule(escaped_char: simple(:x)) { x }
  rule(left: simple(:x)) { x }
  rule(right: simple(:x)) { x }
  rule(plus: simple(:x)) {
    case x
    when Node
      Plus.new(x)
    when String
      Plus.new(Char.new(x))
    else
      raise "unknown type: #{x.class}"
    end
  }
  rule(star: simple(:x)) {
    case x
    when Node
      Star.new(x)
    when String
      Star.new(Char.new(x))
    else
      raise "unknown type: #{x.class}"
    end
  }

  rule(list: sequence(:x)) {
    x.inject do |acc, n|
      case acc
      when Node
        List.new(acc, n)
      else
        raise "unknown type: #{acc.class}"
      end
    end
  }

  rule(branch: subtree(:x)) {
    case x
    when Array
      x.inject do |left, right|
        Branch.new(left, right)
      end
    else
      x
    end
  }
end

#-----------------------------------------
# AST

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

#-----------------------------------------
# Ir

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

#-----------------------------------------
# VM

class Vm
  VmThread = Struct.new(:p, :sp)

  attr_reader :ir, :str, :stack
  def initialize(ir)
    @ir = ir
    @stack = []
  end

  def match(str)
    sp = 0
    match_at(0, sp, str)
  end

  def push(p, sp)
    stack.push(VmThread.new(p, sp))
  end

  def pop
    th = stack.pop
    [th.p, th.sp]
  end

  def init(sp)
    @stack = []
    push(0, sp)
  end

  def match_at(sp, p, str)
    init(sp)
    until stack.empty?
      p, sp = pop

      loop do
        code = ir[p]
        case code.op
        when Ir::OP_CHAR
          break if code.arg1 != str[sp]

          p += 1
          sp += 1
        when Ir::OP_PUSH
          p += 1
          push(p + code.arg1, sp)
        when Ir::OP_JUMP
          p += 1
          p += code.arg1
        when Ir::OP_MATCH
          return true
        end
      end
    end
  end
end

#-----------------------------------------
require 'pp'
require 'pry-byebug'

def dump(pattern)
  p [:pattern, pattern]
  raw_ast = RegexpParser.new.parse(pattern)
  # pp [:raw_ast, raw_ast]
  ast = RegexpTransformer.new.apply(raw_ast)
  pp [:ast, ast]
  pp :ir
  ir = Ir.compile(ast)
  puts ir.map.with_index{|e, i| [i, e.inspect].join(" ")}.join("\n")

  vm = Vm.new(ir)
  str = 'accd'
  p [:match, str, vm.match(str)]
  puts
end

# dump('a*')
# dump('a+')
# dump('ab*c')
# dump('ab+c')
# dump('(ab)*c')
# dump('ab*c')
dump('a+b*ccd')
# dump('a*|b+')
# dump('a*|b+|cc')
