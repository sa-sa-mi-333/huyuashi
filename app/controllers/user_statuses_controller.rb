class UserStatusesController < ApplicationController
  # ログイン後のみ
  before_action :authenticate_user!

  # 積雪観測地点を選択する画面を表示
  def select_station
    @user_status = current_user.user_status
    # 都道府県振興局ごとにまとめた全観測地点のデータを準備 ビューで使う
    @snow_stations_by_prefecture = SnowStation.all.group_by(&:prefecture)
  end

  def update_station
    @user_status = current_user.user_status
    # 更新に成功したらログイン後ルートページへ遷移する
    if @user_status.update(station_number_params)
      redirect_to authenticated_root_path, notice: "観測地点を設定しました"
    # 更新に失敗したらページを再描画する
    else
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
