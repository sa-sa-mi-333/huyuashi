# spec/factories/user_record.rb
FactoryBot.define do
  factory :user_record do
    association :user
    association :snow_station
    
    station_number { snow_station.station_number }
    start_time { Time.current }
    end_time { nil }
    start_snow_depth { nil }
    end_snow_depth { nil }
  end
end
