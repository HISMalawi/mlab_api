FactoryBot.define do
  factory :stock_item do
    name { "MyString" }
    description { "MyText" }
    measurement_unit { "MyString" }
    quantity_unit { 1 }
  end
end
