require "spec_helper"

describe Rgviz::DataTable::Order do
  
  it "correctly compares two rows when sort order is ascending" do
    order = Rgviz::DataTable::Order.new("col", Rgviz::DataTable::Order::ASCENDING)
    left = {"col" => 7}
    right = {"col" => 9}
    order.compare(left, right).should == -1
  end
  
  it "correctly compares two rows when sort order is descending" do
    order = Rgviz::DataTable::Order.new("col", Rgviz::DataTable::Order::DESCENDING)
    left = {"col" => 7}
    right = {"col" => 9}
    order.compare(left, right).should == 1
  end
  
  it "returns zero when they are equal" do
    order = Rgviz::DataTable::Order.new("col", Rgviz::DataTable::Order::DESCENDING)
    left = {"col" => 7}
    right = {"col" => 7}
    order.compare(left, right).should == 0
  end
  
  it "returns zero when the column does not exist" do
    order = Rgviz::DataTable::Order.new("col", Rgviz::DataTable::Order::DESCENDING)
    left = {"a" => 7}
    right = {"a" => 7}
    order.compare(left, right).should == 0
  end
end