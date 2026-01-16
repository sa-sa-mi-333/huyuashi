require "net/http" # rubyでHTTP通信を行う
require "uri" # uriを操作する
require "json" # json形式のデータを取り扱う

# アメダスのデータ(json形式)を取得するクラス
class AmedasDataFetcher
  attr_reader :timestamp # timestampをamedas_importerでも読み込む

  # URL合成用
  BASE_URL = "https://www.jma.go.jp/bosai/amedas/data/map"

  # 日時情報を取得
  def initialize(datetime)
    @datetime = datetime
    @timestamp = build_timestamp
  end

  def fetch
    # buile_urlをURIに変換しでgetリクエストし応答取得
    url = URI.parse(build_url)
    response = Net::HTTP.get_response(url)

    # リクエスト成功なら応答内容をJSON形式に変換
    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    # 失敗ならエラーコードを表示
    else
      Rails.logger.error("Failed to fetch AMEDAS data: #{response.code}")
      nil
    end

  # エラーがあればそれを補足してメッセージを表示する
  rescue StandardError => e
    Rails.logger.error("Error.fetching AMEDAS data: #{e.message}")
    nil
  end

  private

  def build_timestamp
    # amedas_recordのヘルパーメソッドを使う
    fetch_time = AmedasRecord.time_to_hourly_json_date(Time.current)
  end

  def build_url
    # jsonデータを取得するurlを作成
    "#{BASE_URL}/#{@timestamp}.json"
  end
end
