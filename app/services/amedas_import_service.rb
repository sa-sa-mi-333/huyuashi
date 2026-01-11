class AmedasImportService
  # datetimeを準備する
  def initialize(datetime)
    @datetime = datetime
  end

  def execute
    # データ取得操作はamedas_data_fetcherを使う
    fetcher = AmedasDataFetcher.new(@datetime)

    # 別クラスのメソッドでjson形式のデータを取得
    json_data = fetcher.fetch

    # json_dataがなければfalseを返す
    return false if json_data.nil?

    # データ保存はamedas_data_importerを使う
    importer = AmedasDataImporter.new(json_data, fetcher.timestamp)
    importer.import

    # インポートが成功したらtrueを返す
    true

  # 例外エラーを補足してエラーメッセージを表示しfalseを返す
  rescue StandardError => e
    Rails.logger.error("Import failed: #{e.message}")
    false
  end
end
