class AddSnowStaionToAmedasRecords < ActiveRecord::Migration[8.0]
  def change
    # station_numberカラムを追加
    add_column :amedas_records, :station_number, :integer
    # snow_station.station_numberを外部キーとしてamedas_recordsに関連づけ
    add_foreign_key :amedas_records, :snow_stations,
                    column: :station_number,
                    primary_key: :station_number
    # インデックスを追加
    add_index :amedas_records, :station_number
  end
end
