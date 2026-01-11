class AmedasRecord < ApplicationRecord
  belongs_to :snow_station,
    foreign_key: :station_number,
    primary_key: :station_number

  # importメソッドの処理で必ず入力される
  validates :station_number, presence: true
  validates :json_date, presence: true
end
