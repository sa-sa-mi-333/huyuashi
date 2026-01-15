# spec/factories/amedas_record.rb
FactoryBot.define do
  factory :amedas_record do
    # snow_station.idでなくsnow_station.station_numberで紐付け
    association :snow_station

    station_number { snow_station.station_number }

    json_date { 20260101000000 } # null
    temp { 33.4 }
    snow { 22 }
    created_at { Time.current } # null
    updated_at { Time.current } # null
  end
end
