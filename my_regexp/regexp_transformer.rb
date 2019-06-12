require_relative 'ast'

module MyRegexp
  class RegexpTransformer < Parslet::Transform
    rule(char: simple(:x)) { Char.new(x.to_s) }
    rule(escaped: simple(:x)) { Char.new(x.to_s) }
    rule(escaped_char: simple(:x)) { x }
    rule(plus: simple(:x)) { Plus.new(x) }
    rule(star: simple(:x)) { Star.new(x) }
    rule(option: simple(:x)) { Option.new(x) }
    rule(left: simple(:x)) { x }
    rule(right: simple(:x)) { x }

    rule(list: sequence(:x)) {
      # injectは引数なしで、要素数1の場合、x[0]を返すのでいずれにせよNodeオブジェクトが返る
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
