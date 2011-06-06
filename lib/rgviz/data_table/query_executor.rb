module Rgviz
  module DataTable
    class QueryExecutor
    
      ##
      # Execute a query against a collection of rows.
      #
      # @param rows [Array] An array of row data (Hashes).
      # @param query [String|Rgviz::Query] The query to execute.
      # @return [Array] A new data table that has been filtered by the query.
      def self.execute(rows, query)
        
        if rows.nil? or rows.empty?
          return []
        end
        
        if query.is_a? String
          query = Rgviz::Parser.parse(query)
        end
        
        # Convert all hash keys to strings.
        string_keys = []
        rows.each do |row|
          temp = {}
          row.each_pair do |key, value|
            temp[key.to_s] = value
          end
          string_keys << temp
        end
        
        # Get the select part of the statement
        selects = parse_select(query.select)
        
        # Filter the data.
        rows = execute_where(string_keys, query.where)
        
        # Group the data and perform any aggregation.
        rows = execute_grouping(rows, query.group_by, selects)
        
        # Perform ordering
        
        # Perform selects
        
        rows
      end
      
      ##
      #
      def self.execute_grouping(rows, raw_group, selects)
        
        groups = parse_group(raw_group)
        return rows if groups.empty?
        
        rows = group(rows, groups, selects)      
        rows
      end
      
      def self.parse_select(select)
        selects = []
        select.to_s.split(",").each do |select|
          selects << Rgviz::DataTable::Column.factory(select.strip)
        end
        selects
      end
      
      def self.group(rows, groups, selects)
        
        if groups.empty?
          row = rows.first
          selects.each do |select|
            if select.respond_to? :evaluate
              row[select.label] = select.evaluate(rows)
            end
          end
          return [row]
        end
        
        group = groups.shift
        
        buckets = {}
        rows.each do |row|
          buckets[row[group]] ||= []
          buckets[row[group]] << row
        end
        
        rows = []
        buckets.each_key do |bucket|
          rows.concat(group(buckets[bucket], groups, selects))
        end
        rows
      end
    
      ##
      # 
      #
      # @param table []
      # @param where [Rgviz::Where] The where clause part of the query.
      def self.execute_where(rows, where)
        return rows unless where
      
        filters = parse_where(where)
      
        filters.each do |filter|
          filtered_rows = []
          rows.each do |row|
            if filter.match?(row)
              filtered_rows << row
            end
          end
          rows = filtered_rows
        end
        rows
      end
      
      def self.parse_group(group)
        return [] unless group
        groups = group.to_s.split(",")
        groups.each do |group|
          group.strip!
        end
        groups
      end
    
      def self.parse_where(where)
      
        filters = []
      
        # TODO: First break into groups by parenthesis.
      
        # this is very naive...
        ands = where.to_s.split(/(\sand\s)/i)
        count = 0
        ands.each do |raw|
          if count % 2 == 0
            index = 0
            operator = nil
            Rgviz::DataTable::ComparisonFilter.operators.each do |op|
              operator = op if raw.include?(op)
            end
            if operator
              parts = raw.split(operator)
              filters << Rgviz::DataTable::ColumnValueFilter.new(parts[0].strip, parts[1].strip, operator)
            end
          end
          count += 1
        end
        filters
      end
    end
  end
end