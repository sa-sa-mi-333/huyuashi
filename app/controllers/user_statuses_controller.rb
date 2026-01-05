class UserStatusesController < ApplicationController
  # ログイン後のみ
  before_action :authenticate_user!

  def edit
  end

  def update
  end

  def select_station
    # ログインしたユーザーのuser_statusを変更する
    @user_status = current_user.user_status
    @snow_stations_by_prefecture = SnowStation.all.group_by(&:prefecture)
  end

  def update_station
    @user_status = current_user.user_status

    # 成否によって処理を場合分け
    if @user_status.update(station_number_params)
      redirect_to authenticated_root_path, notice: "観測地点を設定しました"
    else
      @snow_stations_by_prefecture = SnowStation.all.group_by(&:prefecture)
      render :select_station, status: :unprocessable_entity
    end
  end

  private

  def station_number_params
    params.require(:user_status).permit(:station_number)
  end
end
