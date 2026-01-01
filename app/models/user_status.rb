class UserStatus < ApplicationRecord
  belongs_to :user

  # バリデーションチェック前に対応
  before_validation :set_default_name, on: :create

  private

  # nameがblankの場合デフォルト名を挿入
  def set_default_name
    self.name = "名無しの雪だるま" if name.blank?
  end
end
