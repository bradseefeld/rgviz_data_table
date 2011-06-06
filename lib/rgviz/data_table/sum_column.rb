module Rgviz
  module DataTable
    class SumColumn < Rgviz::DataTable::Column
      
      def evaluate(rows)
        sum = 0
        rows.each do |row|
          raw = row[column]
          if raw.respond_to? :to_f
            sum += raw.to_f
          elsif raw.respond_to? :to_i
            sum += raw.to_i
          end
        end
        sum
      end
    end
  end
end