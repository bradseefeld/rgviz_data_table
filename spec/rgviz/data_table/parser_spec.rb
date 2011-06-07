require "spec_helper"

describe Rgviz::DataTable::Parser do
  
  context "parsing where conditions" do
    it "does nothing when nil is given" do
      f = Rgviz::DataTable::Parser.parse_where(nil)
      f.should == nil
    end
    
    it "does nothing when an empty string is given" do
      f = Rgviz::DataTable::Parser.parse_where("")
      f.should == nil
    end
    
    it "parses a simple where condition" do
      f = Rgviz::DataTable::Parser.parse_where("age = 25")
      validate_filter(f, "age", "25", Rgviz::DataTable::ComparisonFilter::EQUALS)
    end
  
    it "ignores bad spacing" do
      f = Rgviz::DataTable::Parser.parse_where("   age     =   25   ")
      validate_filter(f, "age", "25", Rgviz::DataTable::ComparisonFilter::EQUALS)
    end
  
    it "parses a where condition with an and statement" do
      f = Rgviz::DataTable::Parser.parse_where("age > 25 and eye = blue")
      f.is_a?(Rgviz::DataTable::CompoundFilter).should be_true
      f.operator.should == Rgviz::DataTable::CompoundFilter::AND
      validate_filter(f.left, "age", "25", Rgviz::DataTable::ComparisonFilter::GREATER_THAN)
      validate_filter(f.right, "eye", "blue", Rgviz::DataTable::ComparisonFilter::EQUALS)
    end
    
    it "parses a where condition with an or statement" do
      f = Rgviz::DataTable::Parser.parse_where("age > 25 or eye = blue")
      f.is_a?(Rgviz::DataTable::CompoundFilter).should be_true
      f.operator.should == Rgviz::DataTable::CompoundFilter::OR
      validate_filter(f.left, "age", "25", Rgviz::DataTable::ComparisonFilter::GREATER_THAN)
      validate_filter(f.right, "eye", "blue", Rgviz::DataTable::ComparisonFilter::EQUALS)
    end
    
    it "handles precedence when or's are mixed with and's" do
      f = Rgviz::DataTable::Parser.parse_where("age >= 25 or hair = black and eye = blue")
      f.is_a?(Rgviz::DataTable::CompoundFilter).should be_true
      f.operator.should == Rgviz::DataTable::CompoundFilter::AND
      validate_filter(f.right, "eye", "blue", Rgviz::DataTable::ComparisonFilter::EQUALS)
      f.left.operator.should == Rgviz::DataTable::CompoundFilter::OR
      validate_filter(f.left.left, "age", "25", Rgviz::DataTable::ComparisonFilter::GREATER_THAN_OR_EQUALS)
      validate_filter(f.left.right, "hair", "black")
    end
    
    it "handles simple parenthesis with and" do
      f = Rgviz::DataTable::Parser.parse_where("(age < 25 or hair = black) and eye = blue")
      f.is_a?(Rgviz::DataTable::CompoundFilter).should be_true
      f.operator.should == Rgviz::DataTable::CompoundFilter::AND
      f.left.is_a?(Rgviz::DataTable::CompoundFilter).should be_true
      f.right.is_a?(Rgviz::DataTable::ColumnValueFilter).should be_true
      validate_filter(f.left.left, "age", "25", Rgviz::DataTable::ComparisonFilter::LESS_THAN)
      validate_filter(f.left.right, "hair", "black")
      validate_filter(f.right, "eye", "blue")
    end
    
    it "handles simple parenthesis with or" do
      f = Rgviz::DataTable::Parser.parse_where("(age < 25 or hair = black) or eye = blue")
      f.is_a?(Rgviz::DataTable::CompoundFilter).should be_true
      f.operator.should == Rgviz::DataTable::CompoundFilter::OR
      f.left.is_a?(Rgviz::DataTable::CompoundFilter).should be_true
      f.right.is_a?(Rgviz::DataTable::ColumnValueFilter).should be_true
      validate_filter(f.left.left, "age", "25", Rgviz::DataTable::ComparisonFilter::LESS_THAN)
      validate_filter(f.left.right, "hair", "black")
      validate_filter(f.right, "eye", "blue")
    end
    
    it "handles simple parenthesis with and on end" do
      f = Rgviz::DataTable::Parser.parse_where("eye = blue aNd     (age < 25 or hair = black)")
      f.is_a?(Rgviz::DataTable::CompoundFilter).should be_true
      f.operator.should == Rgviz::DataTable::CompoundFilter::AND
      f.left.is_a?(Rgviz::DataTable::CompoundFilter).should be_true
      f.right.is_a?(Rgviz::DataTable::CompoundFilter).should be_true
      validate_filter(f.left.left, "eye", "blue")
      validate_filter(f.right.left, "age", "25", Rgviz::DataTable::ComparisonFilter::LESS_THAN)
      validate_filter(f.right.right, "hair", "black")
    end
    
    it "handles simple parenthesis with or on end" do
      f = Rgviz::DataTable::Parser.parse_where("eye = blue oR (age < 25 or hair = black)")
      f.is_a?(Rgviz::DataTable::CompoundFilter).should be_true
      f.operator.should == Rgviz::DataTable::CompoundFilter::OR
      f.left.is_a?(Rgviz::DataTable::CompoundFilter).should be_true
      f.right.is_a?(Rgviz::DataTable::CompoundFilter).should be_true
      validate_filter(f.left.left, "eye", "blue")
      validate_filter(f.right.left, "age", "25", Rgviz::DataTable::ComparisonFilter::LESS_THAN)
      validate_filter(f.right.right, "hair", "black")
    end
    
    it "ignores extra parenthesis" do
      f = Rgviz::DataTable::Parser.parse_where("(eye = blue)")
      f.is_a?(Rgviz::DataTable::ColumnValueFilter)
      validate_filter(f, "eye", "blue")
    end
    
    def validate_filter(filter, column, value, operator = Rgviz::DataTable::ComparisonFilter::EQUALS)
      filter.class.should == Rgviz::DataTable::ColumnValueFilter
      filter.operator.should == operator
      filter.column.should == column
      filter.value.should == value
    end
  end
  
  context "parsing group by statement" do
    it "parses the group by clause" do
      groups = Rgviz::DataTable::Parser.parse_group("age, location,     date")
      groups.length.should == 3
    end

    it "does not fail when group by clause is nil" do
      groups = Rgviz::DataTable::Parser.parse_group(nil)
      groups.length.should == 0
    end
  end
  
  context "parsing select statement" do
    it "parses a select with sum" do
      cols = Rgviz::DataTable::Parser.parse_select("sum(column), column2")
      cols.length.should == 2
      cols.first.class.should == Rgviz::DataTable::SumColumn
      cols.first.label.should == "sum(column)"
    end
  end
end