class AddUserToUserRecords < ActiveRecord::Migration[8.0]
  def change
    # user_idカラムを追加
    add_reference :user_records, :user, foreign_key: true
  end
end
