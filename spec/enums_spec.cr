require "./spec_helper"

describe Enum do
  it "properly assigns EnumItem properties" do
    Enum::AccessoryType::Unknown::Name.should eq "Unknown"
    Enum::AccessoryType::Unknown::Value.should eq 0
    Enum::AccessoryType::Unknown::EnumType.should eq Enum::AccessoryType
  end
end
