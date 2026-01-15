# spec/factories/user_statuses.rb
FactoryBot.define do
  factory :user_status do
    # buildで作成し、コールバックを発火させない
    association :user, factory: :user, strategy: :build
    name { '名無しの雪だるま' }
    action_status { :inactive }
  end
end
