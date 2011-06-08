module Rgviz
  module DataTable
    class Order
      
      ASCENDING = "asc"
      
      DESCENDING = "desc"
      
      def initialize(column, direction)
        @column = column
        @direction = direction
        @direction ||= ASCENDING
      end
      
      def compare(left, right)
        equality = 0
        
        if left[column].nil? && right[column].nil?
          equality = 0
        elsif left[column].nil?
          equality = 1
        elsif right[column].nil?
          equality = -1
        elsif left[column] > right[column]
          equality = 1
        elsif left[column] < right[column]
          equality = -1
        end
        
        if direction == DESCENDING
          equality *= -1
        end
        equality
      end
      
      def column
        @column
      end
      
      def direction
        @direction
      end
    end
  end
end