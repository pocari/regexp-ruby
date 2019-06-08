require_relative 'ast'

module MyRegexp
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
end
