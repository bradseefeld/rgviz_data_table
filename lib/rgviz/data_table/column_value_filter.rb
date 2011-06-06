require "rgviz/data_table/comparison_filter"

module Rgviz
  module DataTable
    class ColumnValueFilter < ComparisonFilter
      
      def initialize(column, value, operator = Rgviz::DataTable::ComparisonFilter::EQUALS)
        super(operator)
        
        @column = column
        @value  = value
        @is_casted = false
      end
      
      def match?(row)
        val = row[@column]
        
        cast_type(val)
        
        super(val, @value)
      end
      
      def column
        @column
      end
      
      def value
        @value
      end
      
      ##
      # Cast the raw type to the complex type if needed.
      def cast_type(complex)
        return if @is_casted
        
        if complex.is_a? Integer and @value.respond_to? :to_i
          @value = @value.to_i
        elsif complex.is_a? Float and @value.respond_to? :to_f
          @value = @value.to_f
        elsif complex.is_a? Time
          @value = Time.parse(@value)
        end
        @is_casted = true
      end
    end
  end
end