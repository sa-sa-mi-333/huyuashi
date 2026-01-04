class AddUniqueIndexToSnowStations < ActiveRecord::Migration[8.0]
  def change
    # 観測地点番号にユニーク制約を追加する(外部キーに設定した場合のエラーを防止)
    add_index :snow_stations, :station_number, unique: true
  end
end
