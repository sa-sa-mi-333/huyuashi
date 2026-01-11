# station_numberとprefevtureを全国のアメダスマスターの内容に置き換える
class UpdateStationNumbersFromNationalMaster < ActiveRecord::Migration[8.0]
  def up
    puts "\n" + "="*60
    puts "観測所番号の更新を開始します"
    puts "="*60

    # ✅ テーブルとデータの存在確認
    unless ActiveRecord::Base.connection.table_exists?('snow_stations')
      puts "❌ snow_stationsテーブルが存在しません"
      return
    end

    station_count = SnowStation.count
    if station_count.zero?
      puts "⚠️  snow_stationsテーブルにデータが存在しません"
      return
    end

    puts "📊 snow_stations: #{station_count}件"

    # 全国版マスターを読み込み
    national_stations = load_national_stations

    # マスター読み込みできなければ処理を中断
    if national_stations.nil? || national_stations.empty?
      puts "❌ 全国版マスターが読み込めませんでした"
      return
    end

    # 更新用カウンタを準備
    updated_count = 0
    not_found_count = 0
    error_count = 0

    # ✅ find_eachではなく、IDを先に取得してから処理する
    station_ids = SnowStation.pluck(:id)
    puts "処理対象: #{station_ids.size}件"

    station_ids.each do |station_id|
      begin
        # ✅ 毎回データベースから最新のデータを取得
        station = SnowStation.find_by(id: station_id)

        # ✅ nilチェック
        if station.nil?
          puts "⚠️  ID: #{station_id} のstationが見つかりませんでした（スキップ）"
          error_count += 1
          next
        end

        # ✅ station_nameがnilの場合もスキップ
        if station.station_name.nil?
          puts "⚠️  ID: #{station_id} のstation_nameがnilです（スキップ）"
          error_count += 1
          next
        end

        national_data = national_stations[station.station_name]

        unless national_data
          not_found_count += 1
          puts "⚠️  #{station.station_name}: 全国版マスタに存在しません"
          next
        end

        # 観測所番号が異なる場合のみ更新
        if station.station_number != national_data[:station_number]
          old_number = station.station_number

          # ✅ トランザクションで囲む
          ActiveRecord::Base.transaction do
            station.update_columns(
              station_number: national_data[:station_number],
              prefecture: national_data[:prefecture],
              updated_at: Time.current
            )
          end

          updated_count += 1
          puts "✅ #{station.station_name}: #{old_number} → #{national_data[:station_number]}"
        end

      rescue StandardError => e
        error_count += 1
        puts "❌ ID: #{station_id} の処理中にエラーが発生しました: #{e.message}"
        puts e.backtrace.first(3).join("\n")
      end
    end

    puts "\n" + "="*60
    puts "観測所番号の更新が完了しました"
    puts "🔄 更新: #{updated_count}件"
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
      puts "❌ 全国版CSVファイルが見つかりません: #{master_csv_dir}"
      return {}
    end

    master_csv_path = master_csv_files.first
    puts "📁 読み込みファイル: #{File.basename(master_csv_path)}"

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
      puts "❌ CSVファイルの読み込み中にエラーが発生しました: #{e.message}"
      return {}
    end

    puts "全国版マスター読み込み： #{national_stations.count}件"
    national_stations
  end
end
