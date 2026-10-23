FactoryBot.define do
  factory :message do
    user
    body { "Hello, world" }
  end
end
