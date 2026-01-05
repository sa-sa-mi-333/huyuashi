class SnowStation < ApplicationRecord
  has_many :user_statuses

  # 表示用の文字列を生成
  def display_info
    "#{station_name}（#{location}）"
  end
end
