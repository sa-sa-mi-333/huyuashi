class AddSnowStationToUserStatuses < ActiveRecord::Migration[8.0]
  def change
    # station_numberカラムを追加
    add_column :user_statuses, :station_number, :integer
    # snow_station.station_numberを外部キーとしてuser_statusに関連づけ
    add_foreign_key :user_statuses, :snow_stations,
                    column: :station_number,
                    primary_key: :station_number
    # インデックスを追加
    add_index :user_statuses, :station_number
  end
end
