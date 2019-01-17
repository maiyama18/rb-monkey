require_relative '../token/token'
require_relative '../object/object'

module RMonkey
  class Evaluator
    TRUE = Boolean.new(true)
    FALSE = Boolean.new(false)
    NULL = Null.new

    class << self
      def eval(node)
        case node
        when Program
          eval_statements(node.statements)
        when ExpressionStatement
          eval(node.expression)
        when IntegerLiteral
          Integer.new(node.value)
        when BooleanLiteral
          Boolean.new(node.value)
        else
          raise EvalError.new "could not eval node #{node.type}"
        end
      end

      # @param [[]Statement] statements
      def eval_statements(statements)
        evaluated = nil
        statements.each do |statement|
          evaluated = eval(statement)
        end
        evaluated
      end
    end
  end
end