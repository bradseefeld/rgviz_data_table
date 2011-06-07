module Rgviz
  module DataTable
    class Parser
      
      ##
      # Parse the group statement.
      #
      # @param group [Rgviz::Group|String] The group by clause
      # @return [Array] An array of strings
      def self.parse_group(group)
        return [] unless group
        groups = group.to_s.split(",")
        groups.each do |group|
          group.strip!
        end
        groups
      end
      
      def self.parse_limit(limit)
        return unless limit
        parts = limit.to_s.split
        
        if parts.length == 1
          return Rgviz::DataTable::Limit.new(0, parts[0])
        elsif parts.length == 2
          return Rgviz::DataTable::Limit.new(parts[0], parts[1])
        end
      end
      
      def self.parse_select(select)
        selects = []
        select.to_s.split(",").each do |select|
          selects << Rgviz::DataTable::Column.factory(select)
        end
        selects
      end
      
      ##
      # Parse the order clause into Order objects.
      #
      # @param order [String] The order clause.
      # @return [Array] The order objects
      def self.parse_order(order)
        orders = []
        order.to_s.split(",").each do |name|
          parts = name.strip.split
          direction = nil
          if parts[1]
            direction = parts[1].downcase
          end
          orders << Rgviz::DataTable::Order.new(parts[0], direction)
        end
        orders
      end
      
      ##
      # Create a filter instantiation from a where clause.
      #
      # @param where [Rgviz::Where|String] The where clause of the query.
      # @return [Rgviz::DataTable::Filter]
      def self.parse_where(where)
        return nil unless where
        return nil if where.to_s.empty?
        
        # First look for parenthesis
        parens = where.to_s.match(/\(.*\)/)
        if parens
          parens = parens[0]
          where = where.to_s.sub(parens, "")
          parens = parens[1, parens.length - 2]
          
          if m = where.match(/^\s+and\s/i)
            where = where.gsub(/^\s+and\s/i, "")
            return Rgviz::DataTable::CompoundFilter.new(parse_where(parens), parse_where(where), Rgviz::DataTable::CompoundFilter::AND)
          elsif m = where.match(/^\s+or\s/i)
            where = where.gsub(/^\s+or\s/i, "")
            return Rgviz::DataTable::CompoundFilter.new(parse_where(parens), parse_where(where), Rgviz::DataTable::CompoundFilter::OR)
          elsif m = where.match(/\sand\s+$/i)
            parens = parens.gsub(/\sand\s+$/i, "")
            return Rgviz::DataTable::CompoundFilter.new(parse_where(where), parse_where(parens), Rgviz::DataTable::CompoundFilter::AND)
          elsif m = where.match(/\sor\s+$/i)
            parens = parens.gsub(/\sor\s+$/i, "")
            return Rgviz::DataTable::CompoundFilter.new(parse_where(where), parse_where(parens), Rgviz::DataTable::CompoundFilter::OR)
          else
            return parse_where(parens)
          end
        end
        
        and_index = where.to_s.index(/\sand\s/i) # TODO: This breaks if its found as part of a value
        or_index  = where.to_s.index(/\sor\s/i)
        
        if and_index # and is given precedence over OR
          left = where.to_s[0, and_index].strip
          right = where.to_s[and_index + 4..-1].strip
          return Rgviz::DataTable::CompoundFilter.new(parse_where(left), parse_where(right), Rgviz::DataTable::CompoundFilter::AND)
        elsif or_index
          left = where.to_s[0, or_index].strip
          right = where.to_s[or_index + 3..-1].strip
          return Rgviz::DataTable::CompoundFilter.new(parse_where(left), parse_where(right), Rgviz::DataTable::CompoundFilter::OR)
        else
          operator = nil
          Rgviz::DataTable::ComparisonFilter.operators.each do |op|
            operator = op if where.to_s.include?(op)
          end
          if operator
            parts = where.to_s.split(operator)
            return Rgviz::DataTable::ColumnValueFilter.new(parts[0].strip, parts[1].strip, operator)
          end
          raise ParseException.new("Unable to understand condition: #{where.to_s}")
        end
      end
    end
  end
end