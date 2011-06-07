require "spec_helper"

describe Rgviz::DataTable::SumColumn do
  
  before(:each) do
    @col = Rgviz::DataTable::SumColumn.new("a", "sum(a)")
  end
  
  it "finds the sum" do
    rows = [{"a" => 1}, {"a" => 3}, {"a" => 1}]
    @col.evaluate(rows).should == 5
  end
  
  it "returns zero when no rows given" do
    @col.evaluate([]).should == 0
  end
  
  it "returns zero when column does not exist" do
    rows = [{"b" => 1}, {"b" => 3}, {"b" => 1}]
    @col.evaluate(rows).should == 0
  end
end