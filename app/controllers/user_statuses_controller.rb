class UserStatusesController < ApplicationController
  # ログイン後のみ
  before_action :authenticate_user!

  def select_station
    # ログインしたユーザーのuser_statusを変更する
    @user_status = current_user.user_status
    # 都道府県振興局ごとにまとめた全観測地点のデータを準備
    @snow_stations_by_prefecture = SnowStation.all.group_by(&:prefecture)
  end

  def update_station
    @user_status = current_user.user_status

    if @user_status.update(station_number_params)
      # 更新に成功したらログイン後ルートページへ遷移する
      redirect_to authenticated_root_path, notice: "観測地点を設定しました"
    else
      # 更新に失敗したらページを再描画する
      @snow_stations_by_prefecture = SnowStation.all.group_by(&:prefecture)
      render :select_station, status: :unprocessable_entity
    end
  end

  private

  # station_number設定専用のストロングパラメータを設定
  def station_number_params
    params.require(:user_status).permit(:station_number)
  end
end
