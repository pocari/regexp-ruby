require_relative 'ast'

module MyRegexp
  class RegexpTransformer < Parslet::Transform
    rule(char: simple(:x)) { Char.new(x.to_s) }
    rule(escaped: simple(:x)) { Char.new(x.to_s) }
    rule(escaped_char: simple(:x)) { x }
    rule(left: simple(:x)) { x }
    rule(right: simple(:x)) { x }
    rule(plus: simple(:x)) { Plus.new(x) }
    rule(star: simple(:x)) { Star.new(x) }

    rule(list: sequence(:x)) {
      x.inject do |acc, n|
        List.new(acc, n)
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
