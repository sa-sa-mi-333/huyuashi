class HomeController < ApplicationController
  # ログイン後のみ
  before_action :authenticate_user!

  def top
    # user_status.station_numberを元に観測地点の情報を表示する
    @station_number = current_user.user_status.station_number
    @station_info = SnowStation.find_by(station_number: @station_number)

    # 気温と積雪の両方が有効な最新のレコードを取得
    @latest_record = AmedasRecord.where(station_number: @station_number)
                                  .where.not(temp: nil)
                                  .where.not(snow: nil)
                                  .order(json_date: :desc)
                                  .first
    # もし両方が有効なレコードがなければ、最新のレコードを取得(ビュー側で欠測表示を行う)
    @latest_record ||= AmedasRecord.where(station_number: @station_number)
                                    .order(json_date: :desc)
                                    .first

    # 過去24時間のレコードから最高・最低気温を取得
    if @latest_record
      # yyyymmddhhmmssの形式から1日遡る(1000000を引く)
      json_date_24h_ago = @latest_record.json_date - 1000000

      # 過去24時間のレコードを取得
      records_24h = AmedasRecord.where(station_number: @station_number)
                                 .where("json_date >= ?", json_date_24h_ago)
                                 .where.not(temp: nil)  # 欠測データを除外

      # 最高気温・最低気温を取得
      @max_temp = records_24h.maximum(:temp)
      @min_temp = records_24h.minimum(:temp)
    end
  end
end
