# csvデータで与えられている全国の観測地点と積雪観測地点の情報をもとに
# テーブルにレコードをインポートするRakeタスク
# 初期設定時に実行することを想定する
require 'csv'

namespace :import do
  desc 'csvファイルから積雪観測地点のデータをインポートする'
  task snow_stations: :environment do
    # CSVファイルパスをディレクトリで指定する
    csv_dir = Rails.root.join('db', 'seeds', 'snow_stations')
    # ディレクトリがない場合はエラーメッセージを表示して処理を終了する
    unless Dir.exist?(csv_dir)
      puts "❌ ディレクトリが見つかりません: #{csv_dir}"
      exit
    end

    csv_files = Dir.glob(File.join(csv_dir, '*.csv'))

    # CSVファイルのがない場合はエラーメッセージを表示して処理を終了する
    if csv_files.empty?
      puts "❌ CSVファイルが見つかりません"
      exit
    end

    # CSV検索結果をメッセージで表示する
    puts "❄️  積雪観測地点のインポート開始..."
    puts "📁 対象ディレクトリ: #{csv_dir}"
    puts "📄 見つかったファイル: #{csv_files.size}件"

    # CSVファイルを1つずつ処理していく
    csv_files.each { |f| puts "   - #{File.basename(f)}" }
    puts ""

    # 処理結果を表示するためのカウンタを準備
    imported_count = 0
    updated_count = 0
    error_count = 0

    # CSVファイルを1行ずつ処理していく
    csv_files.each do |csv_path|
      puts "処理中: #{File.basename(csv_path)}"
      
      # 処理状況を表示するための処理を挟む
      file_line_count = File.readlines(csv_path).size - 1
      puts "📊 CSVファイルの総データ行数: #{file_line_count}件"

      CSV.foreach(csv_path, headers: true, encoding: 'CP932:UTF-8').with_index(1) do |row, index|
        if index % 10 == 0
          print "\r処理中: #{index}/#{file_line_count}行"
          $stdout.flush
        end

        begin
          station_number = row['観測所番号']&.to_i
          next if station_number.nil? || station_number.zero?
          
          # 観測所番号でレコードを検索し、なければ新規作成
          station = SnowStation.find_or_initialize_by(station_number: station_number)
          
          # 緯度・経度を10進数に変換
          latitude_deg = row['緯度(度)']&.to_f
          latitude_min = row['緯度(分)']&.to_f
          longitude_deg = row['経度(度)']&.to_f
          longitude_min = row['経度(分)']&.to_f
          
          # 引数でレコードの属性を設定する インポートのメイン処理部分
          station.assign_attributes(
            # 基本情報
            prefecture: row['都府県振興局'],
            station_name: row['観測所名'],
            station_name_kana: row['ｶﾀｶﾅ名'],
            location: row['所在地'],

            # 緯度経度の度分秒を保存
            latitude_degree: latitude_deg,
            latitude_minute: latitude_min,
            longitude_degree: longitude_deg,
            longitude_minute: longitude_min,

            # 10進数に変換した緯度経度を保存 ヘルパーメソッドで計算する
            latitude: convert_to_decimal_latitude(latitude_deg, latitude_min),
            longitude: convert_to_decimal_longitude(longitude_deg, longitude_min),

            # その他情報
            elevation_meters: row['海面上の高さ(ｍ)']&.to_f,
            station_type: row['種類'],
            observation_start_date: parse_date(row['観測開始年月日']),
            note: row['備考']
          )

          if station.save
            if station.new_record?
              imported_count += 1
            else
              updated_count += 1
            end
          else
            error_count += 1
            puts "\n❌ エラー: #{station.errors.full_messages.join(', ')}"
          end
          
        rescue StandardError => e
          error_count += 1
          puts "\n❌ 例外発生: #{e.message}"
        end
      end
      
      puts "\n✅ #{File.basename(csv_path)} の処理完了"
    end
    
    puts "\n" + "="*50
    puts "✅ 積雪観測地点のインポート完了"
    puts "📊 新規作成: #{imported_count}件"
    puts "📝 更新: #{updated_count}件"
    puts "❌ エラー: #{error_count}件"
    puts "="*50
  end

  private

  # ヘルパーメソッド
  def convert_to_decimal_latitude(degree, minute)
    return nil if degree.nil? || minute.nil?
    degree + (minute / 60.0)
  end
  
  def convert_to_decimal_longitude(degree, minute)
    return nil if degree.nil? || minute.nil?
    degree + (minute / 60.0)
  end
  
  def parse_date(date_string)
    return nil if date_string.blank?
    Date.parse(date_string) rescue nil
  end
end
