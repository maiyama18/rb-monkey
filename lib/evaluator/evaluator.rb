require_relative '../token/token'
require_relative '../object/object'

module RMonkey
  class Evaluator
    TRUE = Boolean.new(true)
    FALSE = Boolean.new(false)
    NULL = Null.new

    class << self
      def eval(node, env)
        case node
        when Program
          eval_program(node, env)
        when BlockStatement
          eval_block_statement(node, env)
        when ExpressionStatement
          eval(node.expression, env)
        when LetStatement
          eval_let_statement(node, env)
        when ReturnStatement
          object = eval(node.expression, env)
          ReturnValue.new(object)
        when IntegerLiteral
          Integer.new(node.value)
        when BooleanLiteral
          node.value ? TRUE : FALSE
        when Identifier
          env.get(node.name)
        when PrefixExpression
          eval_prefix_expression(node, env)
        when InfixExpression
          eval_infix_expression(node, env)
        when IfExpression
          eval_if_expression(node, env)
        when FunctionLiteral
          Function.new(node.parameters, node.body, env)
        else
          raise EvalError.new "could not eval node #{node}"
        end
      end

      def eval_program(node, env)
        evaluated = nil
        node.statements.each do |statement|
          evaluated = eval(statement, env)
          return evaluated.object if evaluated.type == RMonkey::ObjectType::RETURN_VALUE
        end
        evaluated
      end

      def eval_block_statement(node, env)
        evaluated = nil
        node.statements.each do |statement|
          evaluated = eval(statement, env)
          return evaluated if evaluated.type == RMonkey::ObjectType::RETURN_VALUE
        end
        evaluated
      end

      def eval_let_statement(node, env)
        name = node.identifier.name
        value = eval(node.expression, env)
        env.set(name, value)
      end

      def eval_prefix_expression(node, env)
        right = eval(node.right, env)
        case node.operator
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

      def eval_infix_expression(node, env)
        left = eval(node.left, env)
        right = eval(node.right, env)

        raise EvalError.new "type mismatch: #{left} #{node.operator} #{right}" if left.type != right.type

        case left
        when RMonkey::Integer
          eval_integer_infix_expression(node.operator, left, right)
        when RMonkey::Boolean
          eval_boolean_infix_expression(node.operator, left, right)
        else
          raise EvalError.new "unknown expression: #{left} #{node.operator} #{right}"
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
          left == right ? TRUE : FALSE
        when "!="
          left != right ? TRUE : FALSE
        else
          raise EvalError.new "unknown operator: #{operator}"
        end
      end

      def eval_if_expression(node, env)
        condition = eval(node.condition, env)
        case condition
        when TRUE
          eval(node.consequence, env)
        when FALSE, NULL
          node.alternative ? eval(node.alternative, env) : NULL
        else
          eval(node.consequence, env)
        end
      end
    end
  end
end
