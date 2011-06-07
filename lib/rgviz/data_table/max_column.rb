module Rgviz
  module DataTable
    class MaxColumn < Rgviz::DataTable::Column
      
      def evaluate(rows)
        max = nil
        rows.each do |row|
          if max.nil? or max < row[column]
            max = row[column]
          end
        end
        max
      end
    end
  end
end