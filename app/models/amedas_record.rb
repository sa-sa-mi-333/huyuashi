class AmedasRecord < ApplicationRecord
  belongs_to :snow_station,
    foreign_key: :station_number,
    primary_key: :station_number,
    optional: false

  validates :station_number, presence: true # importメソッドの処理で必ず入力される
  validates :json_date, presence: true # importメソッドの処理で必ず入力される
  validates :created_at, presence: true
  validates :updated_at, presence: true
  validates :station_number, uniqueness: { scope: :json_date }  # 同じ観測地点・同じ時刻のデータは1つだけ

  # クラスメソッドとしてjson_date変換を定義
  class << self
    # Time → json_date(bigint)変換
    # 例: 2026-01-15 13:45:30 JST → 20260115134530
    def time_to_json_date(time)
      time.strftime('%Y%m%d%H%M%S').to_i
    end
    
    # json_date(bigint) → Time変換
    # 例: 20260115134530 → 2026-01-15 13:45:30 JST
    def json_date_to_time(json_date)
      date_str = json_date.to_s.rjust(14, '0')
      
      year = date_str[0..3]
      month = date_str[4..5]
      day = date_str[6..7]
      hour = date_str[8..9]
      minute = date_str[10..11]
      second = date_str[12..13]
      
      Time.zone.parse("#{year}-#{month}-#{day} #{hour}:#{minute}:#{second}")
    end
    
    # 時刻を00分00秒に丸める
    # 例: 2026-01-15 13:45:30 → 20260115130000
    def time_to_hourly_json_date(time)
      time.beginning_of_hour.strftime('%Y%m%d%H%M%S').to_i
    end
  end
end
