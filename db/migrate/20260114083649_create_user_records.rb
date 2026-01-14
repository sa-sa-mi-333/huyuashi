class CreateUserRecords < ActiveRecord::Migration[8.0]
  def change
    # MVPリリース時に必要なカラムのみ追加
    create_table :user_records do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :start_snow_depth
      t.integer :end_snow_depth
      t.timestamps
    end
  end
end
