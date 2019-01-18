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
          eval_prefix_expression(node.operator, node.right)
        when InfixExpression
          eval_infix_expression(node.operator, node.left, node.right)
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

      def eval_prefix_expression(operator, right_node)
        right = eval(right_node)
        case operator
        when '!'
          eval_bang_expression(right)
        when '-'
          eval_minus_expression(right)
        else
          raise EvalError.new "could not eval node #{node}"
        end
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

      def eval_infix_expression(operator, left_node, right_node)
        left = eval(left_node)
        right = eval(right_node)

        raise EvalError.new "type mismatch: #{left} #{operator} #{right}" if left.type != right.type

        case left
        when RMonkey::Integer
          eval_integer_infix_expression(operator, left, right)
        when RMonkey::Boolean
          eval_boolean_infix_expression(operator, left, right)
        else
          raise EvalError.new "unknown expression: #{left} #{operator} #{right}"
        end
      end

      def eval_integer_infix_expression(operator, left, right)
        case operator
        when "+"
          RMonkey::Integer.new(left.value + right.value)
        when "-"
          RMonkey::Integer.new(left.value - right.value)
        when "*"
          RMonkey::Integer.new(left.value * right.value)
        when "/"
          RMonkey::Integer.new(left.value / right.value)
        when "=="
          left.value == right.value ? TRUE : FALSE
        when "!="
          left.value != right.value ? TRUE : FALSE
        when ">"
          left.value > right.value ? TRUE : FALSE
        when "<"
          left.value < right.value ? TRUE : FALSE
        else
          raise EvalError.new "unknown operator: #{operator}"
        end
      end

      def eval_boolean_infix_expression(operator, left, right)
        case operator
        when "=="
          left.value == right.value ? TRUE : FALSE
        when "!="
          left.value != right.value ? TRUE : FALSE
        else
          raise EvalError.new "unknown operator: #{operator}"
        end
      end
    end
  end
end