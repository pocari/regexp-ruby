#-----------------------------------------
require 'pp'
require 'pry-byebug'
require_relative 'my_regexp/regexp'

def check(pattern, test_strings)
  p [:pattern, pattern]
  reg = MyRegexp::Regexp.new(pattern)
  pp [:ast, reg.ast]

  pp :ir
  puts reg.ir.map.with_index { |e, i|
    no = format("%2d", i)
    [no, e.inspect].join(" ")
  }.join("\n")

  test_strings.each do |str|
    p [:match, str, reg.match(str) ? 'matched' : 'unmatched']
  end

  puts
end

check('a*b', %w[b ab aab cb])
check('a+b', %w[b ab aab cb])
check('a?b', %w[ab b aab])
check('abc|def', %w[abc def aef])
check('((ab)+|(cd)+)ef', %w[abef cdef ababef cdcdef ababxef abcdef])

