class AddActionStatusToUserStatuses < ActiveRecord::Migration[8.0]
  def change
    # action_statusカラムを追加
    add_column :user_statuses, :action_status, :integer, null: false, default: 0
  end
end
