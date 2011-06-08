require "spec_helper"

describe Rgviz::DataTable::Column do
  
  it "creates a sum column" do
    col = Rgviz::DataTable::Column.factory("sum(column)")
    col.class.should == Rgviz::DataTable::SumColumn
    col.column.should == "column"
    col.label.should == "sum(column)"
  end
  
  it "creates a max column" do
    col = Rgviz::DataTable::Column.factory("max(column)")
    col.is_a?(Rgviz::DataTable::MaxColumn).should be_true
    col.column.should == "column"
    col.label.should == "max(column)"
  end
  
  it "strips extra space" do
    col = Rgviz::DataTable::Column.factory("  some_column   ")
    col.class.should == Rgviz::DataTable::Column
    col.column.should == "some_column"
    col.label.should == col.column
  end
end