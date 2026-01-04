class CreateSnowStations < ActiveRecord::Migration[8.0]
  def change
    create_table :snow_stations do |t|
      # 観測所番号、都道府県振興局、観測所名は必須項目とする
      # 基本情報
      t.integer :station_number, null: false, comment: '観測所番号'
      t.string :prefecture, null: false, comment: '都府県振興局'
      t.string :station_name, null: false, comment: '観測所名'
      t.string :station_name_kana, comment: 'カタカナ名'
      t.string :location, comment: '所在地'

      # 緯度と経度の度分表記　データ型はfloat
      t.float :latitude_degree, comment: '緯度(度)'
      t.float :latitude_minute, comment: '緯度(分)'
      t.float :longitude_degree, comment: '経度(度)'
      t.float :longitude_minute, comment: '経度  (分)'

      # 緯度経度の10進数表記　データ型はdecimal
      t.decimal :latitude, precision: 10, scale: 7, comment: '緯度(10進数)'
      t.decimal :longitude, precision: 10, scale: 7, comment: '経度(10進数)'

      # その他の情報
      t.string :station_type, comment: '種類'
      t.integer :elevation_meters, comment: '海面上の高さ(ｍ)'
      t.date :observation_start_date, comment: '観測開始年月日'
      t.text :note, comment: '備考'

      t.timestamps
    end
  end
end
