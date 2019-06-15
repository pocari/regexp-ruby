require 'parslet'

module MyRegexp
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
        (exp >> op_option).as(:option) |
        op_bol.as(:bol) |
        op_eol.as(:eol) |
        exp
      ).repeat(1).as(:list)
    }

    rule(:exp) {
      (
        str('(') >> regexp >> str(')') |
        (str('\\') >> any.as(:escaped)).as(:escaped_char) |
        match(/[^*+|?)(^$]/).as(:char)
      )
    }

    rule(:op_branch) { str('|') }
    rule(:op_star) { str('*') }
    rule(:op_plus) { str('+') }
    rule(:op_option) { str('?') }
    rule(:op_bol) { str('^') } # begnning of line
    rule(:op_eol) { str('$') } # end of line

    root(:regexp)
  end
end
