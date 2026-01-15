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
end
