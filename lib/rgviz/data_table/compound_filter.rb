module Rgviz
  module DataTable
    class CompoundFilter
      
      AND = "and"
      OR = "or"
      
      def initialize(left, right, operator)
        @left = left
        @right = right
        @operator = operator
      end
      
      def match?(row)
        if operator == OR
          return left.match?(row) || right.match?(row)
        else
          return left.match?(row) && right.match?(row)
        end
      end
      
      def operator
        @operator
      end
      
      def left
        @left
      end
      
      def right
        @right
      end
    end
  end
end