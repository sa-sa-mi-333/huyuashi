class HomeController < ApplicationController
  # ログイン後のみ
  before_action :authenticate_user!

  def top
    # user_status.station_numberを元に観測地点の情報を表示する
    @station_number = current_user.user_status.station_number
    @station_info = SnowStation.find_by(station_number: @station_number)
    @latest_record = AmedasRecord.where(station_number: @station_number)
                                  .order(json_date: :desc)
                                  .first
  end
end
