class UserStatus < ApplicationRecord
  belongs_to :user
  belongs_to :snow_station,
             foreign_key: :station_number,
             primary_key: :station_number,
             optional: true # テーブル作成後に設定する内容なのでnilを許可

  # バリデーションチェック前に対応
  before_validation :set_default_name, on: :create

  # 雪かきの状態を記録する
  enum :action_status, { inactive: 0, active: 1 }, validate: true

  private

  # nameがblankの場合デフォルト名を挿入
  def set_default_name
    self.name = "名無しの雪だるま" if name.blank?
  end
end
