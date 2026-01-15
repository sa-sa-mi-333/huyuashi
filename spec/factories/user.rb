FactoryBot.define do
  factory :user do
    # 一意の値を作成
    sequence(:email) { |n| "user_#{n}@example.com" }
    password { 'password' }
    encrypted_password { 'password' }
    
    # nameを指定した場合のバリエーション
    trait :with_name do
      transient do
        user_name { '太郎' }
      end
      
      after(:build) do |user, evaluator|
        user.name = evaluator.user_name
      end
    end
    
    # 無効なユーザーのバリエーション
    trait :invalid do
      email { '' }
    end
  end
end