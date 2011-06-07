require "spec_helper"

describe Rgviz::DataTable::MaxColumn do
  
  before(:each) do
    @col = Rgviz::DataTable::MaxColumn.new("a", "max(a)")
  end
  
  it "finds the max column" do
    rows = [{"a" => 1}, {"a" => 3}, {"a" => 1}]
    @col.evaluate(rows).should == 3
  end
  
  it "returns nil when no rows given" do
    @col.evaluate([]).should be_nil
  end
  
  it "returns nil when column does not exist" do
    rows = [{"b" => 1}, {"b" => 3}, {"b" => 1}]
    @col.evaluate(rows).should be_nil
  end
end