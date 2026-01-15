class SnowStation < ApplicationRecord
  has_many :user_statuses
  has_many :amedas_records,
           primary_key: :station_number,
           foreign_key: :station_number,
           dependent: :destroy

  validates :station_number, presence:true, uniqueness: true
  validates :prefecture, presence: true
  validates :station_name, presence: true
  validates :created_at, presence: true
  validates :updated_at, presence: true

  # 表示用の文字列を生成
  def display_info
    "#{station_name}（#{location}）"
  end
end
