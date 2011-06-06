module Rgviz
  module DataTable
    class Column
      
      def self.factory(statement)
        col = nil
        if m = statement.match(/sum\((.*)\)/i)
          col = Rgviz::DataTable::SumColumn.new(m[1], statement)
        end
        
        unless col
          col = Rgviz::DataTable::Column.new(statement)
        end
        col
      end
      
      def initialize(col_name, label = nil)
        @column = col_name
        @label = label
        @label ||= col_name
      end
      
      def column
        @column
      end
      
      def label
        @label
      end
    end
  end
end