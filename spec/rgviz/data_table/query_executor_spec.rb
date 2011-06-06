require "spec_helper"

describe Rgviz::DataTable::QueryExecutor do
  
  context "parsing where conditions" do
    it "parses a simple where condition" do
      filters = Rgviz::DataTable::QueryExecutor.parse_where("age = 25")
      filters.length.should == 1
      validate_filter(filters[0], "age", "25", Rgviz::DataTable::ComparisonFilter::EQUALS)
    end
  
    it "ignores bad spacing" do
      filters = Rgviz::DataTable::QueryExecutor.parse_where("   age     =   25   ")
      validate_filter(filters[0], "age", "25", Rgviz::DataTable::ComparisonFilter::EQUALS)
    end
  
    it "parses a where condition with an and statement" do
      filters = Rgviz::DataTable::QueryExecutor.parse_where("age > 25 and eye = blue")
      filters.length.should == 2
      validate_filter(filters[0], "age", "25", Rgviz::DataTable::ComparisonFilter::GREATER_THAN)
      validate_filter(filters[1], "eye", "blue", Rgviz::DataTable::ComparisonFilter::EQUALS)
    end
  end
  
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
  
  it "parses the group by clause" do
    groups = Rgviz::DataTable::QueryExecutor.parse_group("age, location,     date")
    groups.length.should == 3
  end
  
  it "does not fail when group by clause is nil" do
    groups = Rgviz::DataTable::QueryExecutor.parse_group(nil)
    groups.length.should == 0
  end
  
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
  
  it "parses a select with sum" do
    cols = Rgviz::DataTable::QueryExecutor.parse_select("sum(column), column2")
    cols.length.should == 2
    cols.first.class.should == Rgviz::DataTable::SumColumn
    cols.first.label.should == "sum(column)"
  end
  
  it "performs column grouping with a sum" do
    now = Time.now
    rows = [{:column => 5, :start => now}, {:column => 2, :start => now}, {:column => 4, :start => now}]
    rows = Rgviz::DataTable::QueryExecutor.execute(rows, "select sum(column) group by start")
    rows.length.should == 1
    rows.first["sum(column)"].should == 11
  end
  
  def validate_filter(filter, column, value, operator)
    filter.operator.should == operator
    filter.column.should == column
    filter.value.should == value
  end
end