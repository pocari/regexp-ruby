require_relative 'regexp_parser'
require_relative 'regexp_transformer'
require_relative 'vm'
require_relative 'ir'

module MyRegexp
  class Regexp
    attr_reader :ast, :ir
    def initialize(pattern)
      parsed = RegexpParser.new.parse(pattern)
      @ast = RegexpTransformer.new.apply(parsed)
      @ir = Ir.compile(@ast)
    end

    def match(str)
      vm = Vm.new(ir)
      vm.match(str)
    end
  end
end
