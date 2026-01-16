# spec/factories/amedas_record.rb
FactoryBot.define do
  factory :amedas_record do
    # snow_station.idでなくsnow_station.station_numberで紐付け
    association :snow_station
    station_number { snow_station.station_number }

    temp { -33.4 }
    snow { 22 }
    created_at { Time.current } # null
    updated_at { Time.current } # null

    # デフォルト値: 2026-01-15 13:00:00
    json_date { 20260115130000 } # null

    # トレイト: 特定の時刻を指定
    trait :at_time do
      transient do
        # テストで時刻を指定できるようにする
        time { Time.zone.parse('2026-01-15 13:00:00') }
      end

      # 指定された時刻からjson_dateを生成
      json_date { AmedasRecord.time_to_hourly_json_date(time) }
    end
  end
end
