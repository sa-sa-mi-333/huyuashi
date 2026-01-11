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

    saved_count = 0
    skipped_count = 0

    # activerecordのトランザクションを継承して使う
    ActiveRecord::Base.transaction do
      # 全観測地点のデータを観測地点ごとのデータに分割する
      @json_data.each do |station_number_str, weather_data|
        # アメダスのデータではstation_numberが文字列になっているため変換
        station_number = station_number_str.to_i
        # 観測地点のが存在するか確認
        station = SnowStation.find_by(station_number: station_number)
        # 存在しない観測地点を参照しようとした場合は処理しない
        unless station
          Rails.logger.warn("No.#{station_number}の観測地点が見つかりません。処理をスキップします")
          skipped_count += 1
          next
        end

        # AmedasRecordを作成
        observation = AmedasRecord.new(
          station_number: station_number,
          json_date: @timestamp
        )

        # 気温と積雪深を入力するメソッド
        set_weather_values(observation, weather_data)

        # 各データを入力してからデータを保存
        if observation.temp.present? || observation.snow.present?
          Rails.logger.info("保存: station=#{station_number}, temp=#{observation.temp}, snow=#{observation.snow}")
          observation.save!
          saved_count += 1
        else
          Rails.logger.debug("データなし: station=#{station_number}")
          skipped_count += 1
        end
      end
    end

    # 処理内容確認用
    Rails.logger.info("=== インポート完了 ===")
    Rails.logger.info("保存件数: #{saved_count}件")
    Rails.logger.info("スキップ件数: #{skipped_count}件")
  end

  private

  def set_weather_values(observation, data)
    # amedas_recordにjsonデータの値を格納する
    observation.temp = extract_value(data["temp"])
    observation.snow = extract_value(data["snow"])
  end

  # AQCの処理 array[1]が0ならarray[0]のデータを取得する
  def extract_value(array)
    return nil if array.nil? || array.empty?
    array[1] == 0 ? array[0] : nil
  end
end
