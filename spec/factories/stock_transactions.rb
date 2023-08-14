FactoryBot.define do
  factory :stock_transaction do
    type { 1 }
    lot { "MyString" }
    batch { "MyString" }
    quantity { 1 }
    expiry_date { "2023-08-14 14:19:21" }
  end
end
