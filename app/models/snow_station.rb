class SnowStation < ApplicationRecord
  has_many :user_statuses
  has_many :amedas_recordes

  # 表示用の文字列を生成
  def display_info
    "#{station_name}（#{location}）"
  end
end
