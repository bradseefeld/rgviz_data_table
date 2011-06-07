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
        selects = Rgviz::DataTable::Parser.parse_select(query.select)
        
        # Filter the data.
        rows = execute_where(string_keys, query.where)
        
        # Group the data and perform any aggregation.
        rows = execute_grouping(rows, query.group_by, selects)
        
        # Perform ordering
        rows = execute_ordering(rows, query.order_by)
        
        # Perform limits
        rows = execute_offset(rows, query.offset)
        rows = execute_limits(rows, query.limit)
        
        # Perform labels
        
        # Perform selects
        rows = execute_select(rows, selects)
        rows
      end
      
      protected
      
      ##
      # Execute the select statements against the rows. This potentially removes columns from
      # the result set.
      #
      # @param rows [Array] The data
      # @param selects [Array] The columns to keep
      # @return [Array] The result set with only the desired columns
      def self.execute_select(rows, selects)
        return rows unless selects
        return rows if selects.length == 0
        
        columns = []
        selects.each do |select|
          columns << select.label
        end
        
        selected = []
        rows.each do |row|
          new_row = {}
          row.each_pair do |key, value|
            if columns.include?(key)
              new_row[key] = value
            end
          end
          selected << new_row
        end
        selected
      end
      
      ##
      # Execute an offset clause against the given set of data.
      #
      # @param rows [Array] The data
      # @param offset [Rgviz::Offset|String|Integer] The offset
      # @return [Array] The data after the given offset (inclusive)
      def self.execute_offset(rows, offset)
        return rows unless offset
        rows[offset.to_s.to_i..-1] || []
      end
      
      ##
      # Execute a limit clause against the given set of data.
      #
      # @param rows [Array] The data
      # @param offset [Rgviz::Limit|String|Integer] The limit
      # @return [Array] The data limited to the given limit.
      def self.execute_limits(rows, limit)
        return rows unless limit
        rows[0, limit.to_s.to_i]
      end
      
      ##
      # Order the given results by the given critiera.
      #
      # @param rows [Array] The data
      # @param raw_ordering [Array] The order by statements. Processed in chronological order.
      # @return [Array] The sorted data.
      def self.execute_ordering(rows, raw_ordering)
        orders = Rgviz::DataTable::Parser.parse_order(raw_ordering)
        return unless orders
        
        rows.sort do |left, right|
          equality = 0
          index = 0
          while (equality == 0 and index < orders.length)
            equality = orders[index].compare(left, right)
            index += 1
          end
          equality
        end
      end
      
      ##
      # Perform any grouping on the data. If columns are to be aggregated, they
      # are aggregated now.
      #
      # @param rows [Array] The data
      # @param raw_group [Rgviz::Group|String] The raw group by statement.
      # @param selects [Array] The select statements.
      # @return [Array] The grouped data
      def self.execute_grouping(rows, raw_group, selects)        
        groups = Rgviz::DataTable::Parser.parse_group(raw_group)
        return rows if groups.empty?
        group(rows, groups, selects)      
      end
      
      ##
      # Helper method for executing grouping clauses. Does the heavy lifting.
      #
      # @param rows [Array] The data to group
      # @param groups [Array] The group by clauses
      # @param selects [Array] The select statements (in case we need to do any aggregation)
      # @return [Array] The grouped rows.
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
      # Execute any filtering on the given data.
      #
      # @param rows [Array] The rows to execute the filter on.
      # @param where [Rgviz::Where] The where clause part of the query.
      # @return [Array] The filtered data.
      def self.execute_where(rows, where)
        return rows unless where
      
        filter = Rgviz::DataTable::Parser.parse_where(where)
        
        filtered_rows = []
        rows.each do |row|
          if filter.match?(row)
            filtered_rows << row
          end
        end
        filtered_rows
      end
    end
  end
end