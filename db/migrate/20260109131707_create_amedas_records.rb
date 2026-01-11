class CreateAmedasRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :amedas_records do |t|
      t.integer :json_date # jsonデータの日付：yyyymmddhhmmssの形式
      t.float :temp # 気温
      t.integer :snow # 積雪量
      t.timestamps
    end
  end
end
