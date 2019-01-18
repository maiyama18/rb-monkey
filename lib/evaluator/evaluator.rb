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
          node.value ? TRUE : FALSE
        when PrefixExpression
          right = eval(node.right)
          case node.operator
          when '!'
            eval_bang_expression(right)
          when '-'
            eval_minus_expression(right)
          else
            raise EvalError.new "could not eval node #{node}"
          end
        when InfixExpression
          left = eval(node.left)
          right = eval(node.right)
          eval_infix_expression(node.operator, left, right)
        else
          raise EvalError.new "could not eval node #{node}"
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

      def eval_bang_expression(right)
        case right
        when TRUE
          FALSE
        when FALSE
          TRUE
        when NULL
          TRUE
        else
          FALSE
        end
      end

      def eval_minus_expression(right)
        raise EvalError.new "'-' cannot be applied to non-integer: #{right.class}" unless right.instance_of? RMonkey::Integer

        Integer.new(-right.value)
      end

      def eval_infix_expression(operator, left, right)
        raise EvalError.new "type mismatch: #{left} #{operator} #{right}" if left.type != right.type

        case left.type
        when RMonkey::INTEGER
          eval_integer_infix_expression
        else
          raise EvalError.new "unknown operator: #{left} #{operator} #{right}" if left.type != right.type
        end
      end
    end
  end
end