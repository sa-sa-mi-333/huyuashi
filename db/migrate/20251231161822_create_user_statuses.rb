class CreateUserStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :user_statuses do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :name, default: "名無しの雪だるま"
      t.timestamps
    end
  end
end
