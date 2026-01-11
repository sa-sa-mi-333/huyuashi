# station_numberとprefevtureを全国のアメダスマスターの内容に置き換える
class UpdateStationNumbersFromNationalMaster < ActiveRecord::Migration[8.0]
  def up
    puts "\n" + "="*60
    puts "観測所番号の更新を開始します"
    puts "="*60

    # 全国版マスターを読み込み
    national_stations = load_national_stations

    # マスター読み込みできなければ処理を中断
    if national_stations.empty? || national_stations.empty?
      puts "全国版マスターが読み込めませんでした"
      return
    end

    # 更新用カウンタを準備
    updated_count = 0
    not_found_count = 0

    SnowStation.find_each do |station|
      national_data = national_stations[station.station_name]

      unless national_data
        not_found_count += 1
        puts "#{station.station_name}: 全国版マスタに存在しません"
        next
      end

      # 観測所番号が異なる場合のみ更新
      if station.station_number != national_data[:station_number]
        old_number = station.station_number
        new_number = national_data[:station_number]

          # user_statusで登録されている部分を合わせて更新
          ActiveRecord::Base.transaction do
          UserStatus.where(station_number: old_number).update_all(station_number: new_number)

          # update_column: バリデーションをスキップして直接更新
          station.update_columns(
            station_number: national_data[:station_number],
            prefecture: national_data[:prefecture],
            updated_at: Time.current
          )
        end

        updated_count += 1
        puts "#{station.station_name}: #{old_number} → #{new_number}"
      end
    end

    puts "\n" + "="*60
    puts "観測所番号の更新が完了しました"
    puts "更新: #{updated_count}件"
    puts "マスタ未存在: #{not_found_count}件"
    puts "="*60
  end

  def down
    # ロールバックは不可（観測所番号の混同を防ぐ）
    raise ActiveRecord::IrreversibleMigration,
          "観測所番号の更新は元に戻せません"
  end

  private

  def load_national_stations
    require 'csv'

    # 全国版のマスターを読み込み
    # CSVファイルパスをディレクトリで指定する
    puts "全国版マスターファイルをインポート"
    master_csv_dir = Rails.root.join("db", "seeds", "all_stations")
    master_csv_files = Dir.glob(File.join(master_csv_dir, "*.csv"))
    master_csv_path = master_csv_files.first

    # 観測所名 => 観測所番号のマッピングを作成
    national_stations = {}

    CSV.foreach(master_csv_path, headers: true, encoding: "CP932:UTF-8") do |row|
      station_name = row["観測所名"]
      station_number = row["観測所番号"].to_i

      # データがなければスキップ
      next if station_name.blank? || station_number.zero?

      # 観測所名をキーにして観測所番号を格納
      national_stations[station_name] = {
        station_number: station_number,
        prefecture: row["都府県振興局"]
      }
    end

    puts "全国版マスター読み込み： #{national_stations.count}件"
    national_stations # return用
  end
end
