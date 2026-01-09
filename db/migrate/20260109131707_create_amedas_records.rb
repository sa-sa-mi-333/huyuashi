class CreateAmedasRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :amedas_records do |t|
      t.integer :json_date # jsonデータの日付：yyyymmddhhmmssの形式
      t.float :pressure # 現地気圧
      t.float :normal_pressure # 海面気圧
      t.float :temp # 気温
      t.integer :humidity # 湿度
      t.integer :snow # 積雪量
      t.integer :wind_direction # 風向
      t.float :wind # 風速
      t.timestamps
    end
  end
end
