# json形式の情報をレコードに格納
class AmedasDataImporter
  # jsonデータを引数で準備
  def initialize(json_data, timestamp)
    @json_data = json_data
    @timestamp = timestamp
  end

  def import
    # 処理内容確認用
    Rails.logger.info("=== インポート開始 ===")
    Rails.logger.info("JSONデータ件数: #{@json_data&.count}")
    Rails.logger.info("タイムスタンプ: #{@timestamp}")

    # データがなければ処理中断
    return if @json_data.nil? || @json_data.empty?

    # 処理高速化のため、配列に格納して一括でデータを入れ込む方法に変更
    records_for_insert = []

    # 処理高速化のため、全ての観測地点を集合としてメモリに読み込んでおく
    # 存在確認用で重複不要なのでsetクラスとして保持
    stations = SnowStation.pluck(:station_number).to_set

    # 処理しなかったデータのカウント用
    skipped_count = 0

    # activerecordのトランザクションを継承して使う
    ActiveRecord::Base.transaction do
      # 全観測地点のデータを観測地点ごとのデータに分割する
      @json_data.each do |station_number_str, weather_data|
        # アメダスのデータではstation_numberが文字列になっているため変換
        station_number = station_number_str.to_i
        # 存在しない観測地点を参照しようとした場合は処理しない
        unless stations.include?(station_number)
          Rails.logger.warn("No.#{station_number}の観測地点が見つかりません。処理をスキップします")
          skipped_count += 1
          next
        end
        # 格納する値を抽出する
        temp = extract_value(weather_data["temp"])
        snow = extract_value(weather_data["snow"])
        # tempとsnowは欠測でnilの可能性もあるがそのまま格納
        records_for_insert << {
          station_number: station_number,
          json_date: @timestamp,
          temp: temp,
          snow: snow,
          created_at: Time.current,
          updated_at: Time.current
        }
      end

      if records_for_insert.any?
        Rails.logger.info("#{records_for_insert.size} 件のデータ一括挿入開始")
        AmedasRecord.insert_all(records_for_insert)
        Rails.logger.info("挿入完了")
      end
    end

    # 処理内容確認用
    Rails.logger.info("=== インポート完了 ===")
    Rails.logger.info("保存件数: #{records_for_insert.size}件")
    Rails.logger.info("スキップ件数: #{skipped_count}件")
  end

  private

  # AQCの処理 array[1]が0ならarray[0]のデータを取得する
  def extract_value(array)
    return nil if array.nil? || array.empty?
    array[1] == 0 ? array[0] : nil
  end
end
