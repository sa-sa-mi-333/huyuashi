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
    temp_number_offset = 1_000_000
    updates = []
    not_found_count = 0

    SnowStation.find_each do |station|
      national_data = national_stations[station.station_name]

      unless national_data
        not_found_count += 1
        puts "#{station.station_name}: 全国版マスタに存在しません"
        next
      end

      # 観測所番号が異なる場合のみ更新対象に追加
      if station.station_number != national_data[:station_number]
          updates << {
            old_number: station.station_number,
            new_number: national_data[:station_number],
            temp_number: temp_number_offset + station.id,
            prefecture: national_data[:prefecture]
          }
      end
    end

    puts "更新対象: #{updates.size}件"
    return if updates.empty?

    # 一時的な番号に置き換える
    puts "\n一時的な番号に変更"

    updates.each do |update|
      ActiveRecord::Base.transaction do
        # user_statusesを一時番号に更新
        UserStatus.where(station_number: update[:old_number])
                  .update_all(station_number: update[:temp_number])
        
        # snow_stationsを一時番号に更新
        update[:station].update_columns(
          station_number: update[:temp_number],
          updated_at: Time.current
        )
        
        puts "🔄 #{update[:station].station_name}: #{update[:old_number]} → #{update[:temp_number]} (一時)"
      end
    end

    # 最終的な番号に変更
    puts "\n【フェーズ2】最終的な番号に変更中..."
    
    updated_count = 0
    skipped_count = 0
    
    updates.each do |update|
      begin
        ActiveRecord::Base.transaction do
          # user_statusesを最終番号に更新
          affected_rows = UserStatus.where(station_number: update[:temp_number])
                                    .update_all(station_number: update[:new_number])
          
          # snow_stationsを最終番号に更新
          update[:station].update_columns(
            station_number: update[:new_number],
            prefecture: update[:prefecture],
            updated_at: Time.current
          )
          
          updated_count += 1
          puts "#{update[:station].station_name}: #{update[:old_number]} → #{update[:new_number]} (user_statuses: #{affected_rows}件)"
        end

      rescue ActiveRecord::InvalidForeignKey => e
        # エラーが発生した場合は元の番号に戻す
        ActiveRecord::Base.transaction do
          UserStatus.where(station_number: update[:temp_number])
                    .update_all(station_number: update[:old_number])
          
          update[:station].update_columns(
            station_number: update[:old_number],
            updated_at: Time.current
          )
        end
        
        skipped_count += 1
        puts "⚠️  #{update[:station].station_name}: #{update[:old_number]} → #{update[:new_number]} (外部キー制約エラーによりスキップ)"
        puts "    エラー詳細: #{e.message}"
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
