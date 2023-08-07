FactoryBot.define do
  factory :stock_requisition do
    quantity_requested { "MyString" }
    quantity_issued { "MyString" }
    quantity_collected { "MyString" }
  end
end
