# station_numberとprefevtureを全国のアメダスマスターの内容に置き換える
class UpdateStationNumbersFromNationalMaster < ActiveRecord::Migration[8.0]
  # トランザクション起因のエラーが発生するため追加
  disable_ddl_transaction!

  def up
    puts "\n" + "="*60
    puts "観測所番号の更新を開始します"
    puts "="*60

    # テーブルとデータの存在確認 存在しなければ処理を中断
    unless ActiveRecord::Base.connection.table_exists?('snow_stations')
      puts "⚠️ snow_stationsテーブルが存在しません"
      return
    end

    # snow_stationのデータ個数をカウント 0なら処理を中断
    station_count = SnowStation.count
    if station_count.zero?
      puts "⚠️ snow_stationsテーブルにデータが存在しません"
      return
    end

    # 現在のsnow_stationのデータ個数を表示
    puts "snow_stations: #{station_count}件"

    # 全国版マスターを読み込み プライベートメソッドで処理
    national_stations = load_national_stations

    # マスター読み込みできなければ処理を中断
    if national_stations.nil? || national_stations.empty?
      puts "全国版マスターが読み込めませんでした"
      return
    end

    # 更新用カウンタを準備
    updated_count = 0
    not_found_count = 0
    error_count = 0
    skipped_count = 0

    # snow_stationデータのidカラム内容を取得
    station_ids = SnowStation.pluck(:id)
    puts "処理対象: #{station_ids.size}件"

    # 通し番号を振りながらstation_idsをループ処理
    station_ids.each_with_index do |station_id, index|
      begin

        # 進捗を表示
        if (index + 1) % 50 == 0
          puts "進捗: #{index + 1}/#{station_ids.size}件処理完了 (更新:#{updated_count}件, スキップ:#{skipped_count}件, エラー:#{error_count}件)"
        end

        # snow_stationから最新のデータを取得
        station = SnowStation.find_by(id: station_id)
        # マスターデータのstation_nameを取得
        national_data = national_stations[station.station_name]

        # snow_stationのnilチェック エラーになった部分は飛ばして次へ
        if station.nil?
          puts "⚠️ ID: #{station_id} のstationが見つかりませんでした（スキップ）"
          error_count += 1
          next
        end

        # station_nameのnilチェック エラーになった部分は飛ばして次へ
        if station.station_name.nil?
          puts "⚠️ ID: #{station_id} のstation_nameがnilです（スキップ）"
          error_count += 1
          next
        end

        # マスターデータの中で合致する名前が見つからない場合は飛ばして次へ
        unless national_data
          not_found_count += 1
          puts "⚠️ #{station.station_name}: 全国版マスタに存在しません"
          next
        end

        # 該当データがあり、かつ観測所番号が新旧で異なる場合のみ更新処理を行う
        if station.station_number != national_data[:station_number]
          old_number = station.station_number
          new_number = national_data[:station_number]

          # 重複チェック(同じstation_numberが既に存在するか)
          existing_station = SnowStation.where.not(id: station.id)
                                        .find_by(station_number: new_number)
          if existing_station
            puts "⚠️  #{station.station_name}: 観測所番号 #{new_number} が既に存在するためスキップ"
            puts "    既存: #{existing_station.station_name} (ID: #{existing_station.id})"
            skipped_count += 1
            next
          end

          # user_statusesがstation_numberを参照していれば、先に更新処理を行う
          if ActiveRecord::Base.connection.table_exists?('user_statuses')
            referenced_count = UserStatus.where(station_number: old_number).count

            # 参照箇所の更新
            if referenced_count > 0
              puts "⚠️  #{station.station_name}: user_statusesによる参照件数 (#{referenced_count}件)"
              puts "    旧番号: #{old_number}, 新番号: #{new_number}"
              UserStatus.where(station_number: old_number).update_all(station_number: new_number)
              puts "user_statusesを更新しました"
            end
          end

          # snow_stationsの観測地点番号と都道府県振興局の値を更新
          station.update_columns(
            station_number: national_data[:station_number],
            prefecture: national_data[:prefecture],
            updated_at: Time.current
          )
          updated_count += 1
        end
      end
    end

    puts "\n" + "="*60
    puts "観測所番号の更新が完了しました"
    puts "🔄 更新: #{updated_count}件"
    puts "⏭️  スキップ: #{skipped_count}件"
    puts "⚠️  マスタ未存在: #{not_found_count}件"
    puts "❌ エラー: #{error_count}件"
    puts "="*60
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "観測所番号の更新は元に戻せません"
  end

  private

  def load_national_stations
    require 'csv'

    puts "全国版マスターファイルをインポート"
    master_csv_dir = Rails.root.join("db", "seeds", "all_stations")
    master_csv_files = Dir.glob(File.join(master_csv_dir, "*.csv"))

    if master_csv_files.empty?
      puts "全国版CSVファイルが見つかりません: #{master_csv_dir}"
      return {}
    end

    master_csv_path = master_csv_files.first
    puts "読み込みファイル: #{File.basename(master_csv_path)}"

    national_stations = {}

    begin
      CSV.foreach(master_csv_path, headers: true, encoding: "CP932:UTF-8") do |row|
        station_name = row["観測所名"]
        station_number = row["観測所番号"]&.to_i

        next if station_name.blank? || station_number.zero?

        national_stations[station_name] = {
          station_number: station_number,
          prefecture: row["都府県振興局"]
        }
      end

    rescue StandardError => e
      puts "CSVファイルの読み込み中にエラーが発生しました: #{e.message}"
      return {}
    end

    puts "全国版マスター読み込み： #{national_stations.count}件"
    national_stations
  end
end
