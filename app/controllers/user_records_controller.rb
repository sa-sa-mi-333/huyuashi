class UserRecordsController < ApplicationController
  # ログイン後のみ
  before_action :authenticate_user!

  def index
    @user_records = current_user.user_records
  end


  def new
    @user_record = UserRecord.new
  end

  def create
    # ログインユーザーの雪かきレコードを作成
    @user_record = current_user.user_records.build(
      station_number: current_user.user_status.station_number,
      start_time: Time.current
    )

    # 積雪深を計算
    @user_record.start_snow_depth = @user_record.calculate_snow_depth(@user_record.start_time)

    if @user_record.save
      current_user.user_status.update(action_status: :active)
      redirect_to authenticated_root_path, notice: "雪かきを開始しました"
    else
      flash.now[:danger] = "レコード作成に失敗しました"
      redirect_to authenticated_root_path, alert: :unprocessable_entity
    end
  end

  def update(user_record_param)
    # 詳細情報を追加するときに使う予定
  end

  def finish
    # 雪かき中のレコードを終了させるためのメソッド 雪質などの詳細を追加するのは別メソッドで対応
    @user_record = current_user.user_records.find_by(end_time: nil)

    if @user_record.nil?
      flash[:danger] = "進行中の雪かきレコードが見つかりません"
      redirect_to authenticated_root_path, alert: :unprocessable_entity
      return
    end

    @user_record.end_time = Time.current

    # 積雪深を計算
    @user_record.start_snow_depth = @user_record.calculate_snow_depth(@user_record.start_time)
    @user_record.end_snow_depth = @user_record.calculate_snow_depth(@user_record.end_time)

    if @user_record.save
      current_user.user_status.update(action_status: :inactive)
      redirect_to authenticated_root_path, notice: "雪かき終了！お疲れさまでした！"
    else
      flash.now[:danger] = "レコード更新に失敗しました"
      redirect_to authenticated_root_path, alert: :unprocessable_entity
    end
  end

  private

  # 雪かき詳細情報を追加するときに設定する
  def user_record_param
  end
end
