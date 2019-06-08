#-----------------------------------------
require 'pp'
require 'pry-byebug'
require_relative 'my_regexp/regexp'

def check(pattern)
  p [:pattern, pattern]
  reg = MyRegexp::Regexp.new(pattern)
  pp [:ast, reg.ast]

  pp :ir
  puts reg.ir.map.with_index{|e, i| [i, e.inspect].join(" ")}.join("\n")

  str = 'accd'
  p [:match, str, reg.match(str)]
  puts
end

# check('a*')
# check('a+')
# check('ab*c')
# check('ab+c')
# check('(ab)*c')
# check('ab*c')
check('a+b*ccd')
# check('a*|b+')
# check('a*|b+|cc')
