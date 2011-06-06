module Rgviz
  module DataTable
    
    ##
    # A base filter class that handles the operator logic of the filter.
    class ComparisonFilter
      
      EQUALS = "="
      NOT_EQUALS = "!="
      LESS_THAN = "<"
      LESS_THAN_OR_EQUALS = "<="
      GREATER_THAN = ">"
      GREATER_THAN_OR_EQUALS = ">="
      
      def self.operators
        [EQUALS, NOT_EQUALS, LESS_THAN, LESS_THAN_OR_EQUALS, GREATER_THAN, GREATER_THAN_OR_EQUALS]
      end
      
      ##
      # Initialize the filter with an operator type.
      #
      # @param operator [String] The operator type.
      def initialize(operator)
        @operator = operator
      end
      
      ##
      # Determine if the two given values match based on the operator.
      #
      # @param left [Object] The left hand side of the comparison
      # @param right [Object] The right hand side of the comparison
      # @return [Boolean] True if they are a match.
      def match?(left, right)        
        return case operator
        when EQUALS
          left == right
        when NOT_EQUALS
          left != right
        when LESS_THAN
          left < right
        when LESS_THAN_OR_EQUALS
          left <= right
        when GREATER_THAN
          left > right
        when GREATER_THAN_OR_EQUALS
          left >= right
        else
          false
        end
      end
      
      ##
      # Fetch the operator for this filter.
      #
      # @return [String] The operator type
      def operator
        @operator
      end
    end
  end
end