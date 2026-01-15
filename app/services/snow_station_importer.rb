require "csv"

class SnowStationImporter
  # CSVデータを元にアメダスの観測地点の情報をデータベースにインポートするメソッド
  def self.import
    new.import
  end

  def import
    # マスターをインポート
    master_csv_path = get_master_csv_path
    snow_csv_path = get_snow_csv_path

    # 全国版マスターの読み込み
    national_stations = load_national_stations(master_csv_path)

    # 全国版マスターと積雪観測地点マスターの緯度経度を突き合わせて情報をまとめる
    puts "\n=== インポート用配列作成 ==="
    pre_data = []
    not_found_stations = []
    current_time = Time.current

    CSV.foreach(snow_csv_path, headers: true, encoding: "CP932:UTF-8") do |snow_row|
      # 緯度経度を10進数に変換
      snow_latitude_deg = convert_to_decimal_latitude(
        snow_row["緯度(度)"].to_f,
        snow_row["緯度(分)"].to_f
      )
      snow_longitude_deg = convert_to_decimal_longitude(
        snow_row["経度(度)"].to_f,
        snow_row["経度(分)"].to_f
      )
      # 緯度経度がnilの場合は記録して次へ
      if snow_latitude_deg.nil? || snow_longitude_deg.nil?
        not_found_stations << {
          station_number: snow_row["観測所番号"],
          station_name: snow_row["観測所名"],
          prefecture: snow_row["都府県振興局"],
          location: snow_row["所在地"],
          reason: "緯度経度がnil"
        }
        next
      end

      # 緯度経度で複合キーを設定
      composite_key = "#{snow_latitude_deg}_#{snow_longitude_deg}"

      # 全国版マスターにマッチする情報があるか確認
      national_data = national_stations[composite_key]

      # 緯度経度がnilの場合は記録して次へ
      if national_data.nil?
        not_found_stations << {
          station_number: snow_row["観測所番号"],
          station_name: snow_row["観測所名"],
          prefecture: snow_row["都府県振興局"],
          location: snow_row["所在地"],
          latitude: snow_latitude,
          longitude: snow_longitude,
          reason: "全国版マスターに該当データなし"
        }
        next
      end

      # 先に関連テーブルの値を更新する
      old_number = snow_row["観測所番号"]
      new_number = national_data[:station_number]
      update_user_statuses_references(old_number, new_number)
      update_amedas_records_references(old_number, new_number)

      # 全国マスターの複合キーにマッチする情報をpre_dataに格納する
      if national_data
        pre_data << {
          # 基本情報
          station_number: national_data[:station_number],
          prefecture: national_data[:prefecture],
          station_name: national_data[:station_name],
          station_name_kana: snow_row["ｶﾀｶﾅ名"],
          location: national_data[:location],

          # 緯度経度の度分秒を保存
          latitude_degree: snow_row["緯度(度)"],
          latitude_minute: snow_row["緯度(分)"],
          longitude_degree: snow_row["経度(度)"],
          longitude_minute: snow_row["経度(分)"],

          # 10進数に変換した緯度経度を保存 ヘルパーメソッドで計算する
          latitude: national_data[:latitude],
          longitude: national_data[:longitude],

          # その他情報
          elevation_meters: snow_row["海面上の高さ(ｍ)"]&.to_f,
          station_type: snow_row["種類"],
          observation_start_date: parse_date(snow_row["観測開始年月日"]),
          note: snow_row["備考"],
          created_at: current_time,
          updated_at: current_time
        }
      end
    end

    puts "  配列に格納：#{pre_data.size}件"
    puts "  積雪観測地点が見つからないデータ: #{not_found_stations.size}件"

    puts "\nインポート開始"
    #if ActiveRecord::Base.connection.table_exists?("snow_stations")
      #if SnowStation.exists?
        #SnowStation.delete_all
        #puts "既存データを削除しました"
      #else
        #puts "既存データがありません"
      #end
    #else
      puts "初期データを作成します"
    #end

    # データ作成処理
    # 主キーをstation_numberとしているので、明示的に示す
    SnowStation.insert_all!(pre_data)
    result_count = SnowStation.count
    puts "  #{result_count}件のデータをインポートしました"
  end

  private
  # 全国マスターファイルをインポート
  def get_master_csv_path
    puts "\n=== CSVデータを準備 ==="
    puts "  全国版マスターファイルをインポート"
    master_csv_dir = Rails.root.join("db", "seeds", "all_stations")
    puts "    対象ディレクトリ: #{master_csv_dir}"
    master_csv_files = Dir.glob(File.join(master_csv_dir, "*.csv"))
    # 最新のデータをディレクトリ直下に1つだけ配置 複数ある場合は処理しない
    unless master_csv_files.count == 1
      raise "全国版マスターファイルが複数あります。確認してください。"
    end
    master_csv_path = master_csv_files.first
    puts "    使用するファイル: #{master_csv_path}"
    master_csv_path
  end

  # 積雪観測地点マスターをインポート
  def get_snow_csv_path
    puts "  積雪観測地点情報をインポート"
    snow_csv_dir = Rails.root.join("db", "seeds", "snow_stations")
    puts "    対象ディレクトリ: #{snow_csv_dir}"
    snow_csv_files = Dir.glob(File.join(snow_csv_dir, "*.csv"))
    # 最新のデータをディレクトリ直下に1つだけ配置 複数ある場合は処理しない
    unless snow_csv_files.count == 1
      raise "観測地点用マスターファイルが複数あります。確認してください。"
    end
    snow_csv_path = snow_csv_files.first
    puts "    使用するファイル: #{snow_csv_path}"
    snow_csv_path
  end

  # 全国版マスターの重複チェック
  def load_national_stations(master_csv_path)
    national_stations = {}
    composite_key_counts = Hash.new(0) # 複合キーの出現回数をカウント
    duplicate_keys = [] # 重複しているものを配列で記録
    national_stations = {} # 重複を上書きしてハッシュで記録

    CSV.foreach(master_csv_path, headers: true, encoding: "CP932:UTF-8").with_index(1) do |master_row, line_number|
      # 緯度経度を10進数に変換
      master_latitude_deg = convert_to_decimal_latitude(
        master_row["緯度(度)"].to_f,
        master_row["緯度(分)"].to_f
      )
      master_longitude_deg = convert_to_decimal_longitude(
        master_row["経度(度)"].to_f,
        master_row["経度(分)"].to_f
      )
      # 緯度経度がnilの場合はスキップ
      next if master_latitude_deg.nil? || master_longitude_deg.nil?

      # 緯度経度で複合キーを設定
      composite_key = "#{master_latitude_deg}_#{master_longitude_deg}"
      # 複合キーの出現回数をカウント
      composite_key_counts[composite_key] += 1

      # 緯度経度をキーとして保存(重複する場合は上書きされる)
      national_stations[composite_key] = {
        station_number: master_row["観測所番号"],
        prefecture: master_row["都府県振興局"],
        station_name: master_row["観測所名"],
        location: master_row["所在地"],
        latitude: master_latitude_deg,
        longitude: master_longitude_deg
      }

      # 重複している場合は記録
      if composite_key_counts[composite_key] == 2
        duplicate_keys << {
          composite_key: composite_key,
          first_station: national_stations[composite_key],
          second_station: {
            prefecture: master_row["都府県振興局"],
            station_name: master_row["観測所名"],
            station_number: master_row["観測所番号"],
            location: master_row["所在地"],
            latitude: master_latitude_deg,
            longitude: master_longitude_deg
          }
        }
      end
    end

    puts "\n=== 全国版マスター読み込み結果 ==="
    puts "  処理成功: #{national_stations.size}件"
    puts "  総レコード数: #{composite_key_counts.values.sum}件"
    puts "  重複キー数: #{duplicate_keys.size}件"

    if duplicate_keys.any?
      puts "\n=== 重複している複合キー ==="
      duplicate_keys.each do |dup|
        puts "  複合キー: #{dup[:composite_key]}"
        puts "    1件目: #{dup[:first_station][:prefecture]} - #{dup[:first_station][:station_name]} (#{dup[:first_station][:station_number]} #{dup[:first_station][:location]})"
        puts "    2件目: #{dup[:second_station][:prefecture]} - #{dup[:second_station][:station_name]} (#{dup[:second_station][:station_number]} #{dup[:second_station][:location]})"
      end
    end
    national_stations
  end

  # 10進数に変換した緯度を返す 小数点4桁で丸める
  def convert_to_decimal_latitude(degree, minute)
    return nil if degree.nil? || minute.nil?
    (degree + (minute / 60.0)).round(4)
  end

  # 10進数に変換した経度を返す 小数点4桁で丸める
  def convert_to_decimal_longitude(degree, minute)
    return nil if degree.nil? || minute.nil?
    (degree + (minute / 60.0)).round(4)
  end

  # 観測開始年月日がnilのときの対応
  def parse_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string) rescue nil
  end

  # user_statusesの参照を更新
  def update_user_statuses_references(old_number, new_number)
    # user_statusesテーブルが存在するか確認
    return unless ActiveRecord::Base.connection.table_exists?("user_statuses")

    referenced_count = UserStatus.where(station_number: old_number).count

    if referenced_count > 0
      puts "  📌 user_statusesの参照を更新 (#{referenced_count}件)"
      UserStatus.where(station_number: old_number).update_all(station_number: new_number)
      puts "  ✅ user_statuses更新完了"
    end
  end

  # amedas_recordsの参照を更新
  def update_amedas_records_references(old_number, new_number)
    # amedas_recordsテーブルが存在するか確認
    return unless ActiveRecord::Base.connection.table_exists?("amedas_records")

    referenced_count = AmedasRecord.where(station_number: old_number).count

    if referenced_count > 0
      puts "  📌 amedas_recordsの参照を更新 (#{referenced_count}件)"
      AmedasRecord.where(station_number: old_number).update_all(station_number: new_number)
      puts "  ✅ amedas_records更新完了"
    end
  end
end
