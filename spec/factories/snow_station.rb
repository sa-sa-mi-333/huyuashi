# spec/factories/snow_station.rb
FactoryBot.define do
  factory :snow_station do
    # 宗谷,11900,雪,浜鬼志別,ﾊﾏｵﾆｼﾍﾞﾂ,宗谷郡猿払村浜鬼志別,45,20.1,142,10.2,13,昭58.10.5
    sequence(:station_number) { |n| "#{n}" } # uniqueness
    prefecture { '北海道' } # null
    station_name { '浜鬼志別' } # null
    station_name_kana { 'ハマオニシベツ' }
    location { '宗谷郡猿払村浜鬼志別' }
    latitude_degree { 45 } # 緯度(度)
    latitude_minute { 20.1 } # 緯度(分)
    longitude_degree { 142 } # 経度(度)
    longitude_minute { 10.2 } # 経度(分)
    latitude { 45.335 }
    longitude { 142.17 }
    station_type { '雪' }
    elevation_meters { 13 }
    observation_start_date { Date.new(1983, 10, 5) }
    note { nil }
    created_at { Time.current } # null
    updated_at { Time.current } # null

    # 複数のAmedasRecordを持つバリエーション
    # snow_station.idでなくsnow_station.station_numberで紐付け
    trait :with_records do
      after(:create) do |snow_station|
        create_list(:amedas_record, 3,
                    snow_station: snow_station,
                    station_number: snow_station.station_number)
      end
    end
  end
end