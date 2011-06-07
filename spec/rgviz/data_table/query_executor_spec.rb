require "spec_helper"

describe Rgviz::DataTable::QueryExecutor do
  
  context "executing where conditions" do
    it "executes a simple equals query with ints" do
      rows = [{:age => 25}, {:age => 26}]
      table = Rgviz::DataTable::QueryExecutor.execute(rows, "select * where age = 25")
      table.length.should == 1
    end
  
    it "executes a simple and query with ints" do
      rows = [{:age => 25, :friends => 3}, {:age => 25, :friends => 7}]
      table = Rgviz::DataTable::QueryExecutor.execute(rows, "select * where age = 25 and friends > 5")
      table.length.should == 1
    end
  
    it "executes a exclusive query with ints" do
      rows = [{:age => 25}, {:age => 26}]
      table = Rgviz::DataTable::QueryExecutor.execute(rows, "select * where age < 25 and page > 26")
      table.length.should == 0
    end
  
    it "doesnt fail when no rows are given" do
      rows = Rgviz::DataTable::QueryExecutor.execute(nil, "select * where age < 3")
      rows.length.should == 0
    end
  
    it "filters dates" do
      now = Time.at(Time.now.to_i) # Round milliseconds off
      rows = [{:created_at => now}, {:created_at => now - 100}]
      rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select * where created_at = '#{now}'")
      rows.length.should == 1
    end
  end
  
  context "executing group by conditions" do
    it "performs grouping without aggregation" do
      rows = [{:column => 1}, {:column => 1}, {:column => 2}]
      rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select * group by column")
      rows.length.should == 2
    end
  
    it "performs multiple column grouping without aggregation" do
      rows = [{:column1 => 1}, {:column1 => 1, :column2 => 3}, {:column1 => 1}]
      rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select * group by column1, column2")
      rows.length.should == 2
    end
  
    it "performs column grouping with a sum" do
      now = Time.now
      rows = [{:column => 5, :start => now}, {:column => 2, :start => now}, {:column => 4, :start => now}]
      rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select sum(column) group by start")
      rows.length.should == 1
      rows.first["sum(column)"].should == 11
    end
  end
  
  context "executing order conditions" do
    it "orders a list by a single condition" do
      rows = [{:column => 6}, {:column => 8}, {:column => 4}]
      rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select * order by column")
      rows.length.should == 3
      rows[0]["column"].should == 4
      rows[1]["column"].should == 6
      rows[2]["column"].should == 8
    end
    
    it "orders a list by multiple dimensions" do
      rows = [{:a => 5, :b => 2}, {:a => 5, :b => 3}, {:a => 4, :b => 1}]
      rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select * order by a, b")
      rows.length.should == 3
      rows[0]["b"].should == 1
      rows[1]["b"].should == 2
      rows[2]["b"].should == 3
    end
    
    it "respects an explicit direction" do
      rows = [{:a => 4}, {:a => 7}, {:a => 19}]
      rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select * order by a deSc")
      rows.length.should == 3
      rows[0]["a"].should == 19
      rows[1]["a"].should == 7
      rows[2]["a"].should == 4
    end
  end
  
  context "executing limits" do
    it "limits the result set" do
      rows = [{:a => 4}, {:a => 3}, {:a => 5}]
      rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select * limit 2")
      rows.length.should == 2
    end
    
    it "limits the result set to zero" do
      rows = [{:a => 4}, {:a => 3}, {:a => 5}]
      rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select * limit 0")
      rows.length.should == 0
    end
    
    it "limits with offset" do
      rows = [{:a => 4}, {:a => 3}, {:a => 5}]
      rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select * limit 1 offset 1")
      rows.length.should == 1
      rows[0]["a"].should == 3
    end
    
    it "performs an offset" do
      rows = [{:a => 4}, {:a => 3}, {:a => 5}]
      rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select * offset 1")
      rows.length.should == 2
    end
    
    it "returns an empty array when too big an offset is given" do
      rows = [{:a => 4}, {:a => 3}, {:a => 5}]
      rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select * offset 90")
      rows.length.should == 0
    end
  end
  
  context "executing select statements" do
    it "selects all when star is given" do
      rows = [{:a => 1, :b => 2, :c => 3}]
      rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select *")
      rows.length.should == 1
      rows.first.length.should == 3
    end
    
    it "restricts column selection" do
      rows = [{:a => 1, :b => 2, :c => 3}]
      rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select a,b")
      rows.length.should == 1
      rows.first.length.should == 2
    end
  end
end