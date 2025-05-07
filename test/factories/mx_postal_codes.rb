FactoryBot.define do
  factory :mx_postal_code do
    state { nil }
    city { nil }
    postal_code { "MyString" }
    neighborhood { "MyString" }
  end
end
