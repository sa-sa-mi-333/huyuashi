# 前回雪かき終了時の積雪深と現在地の最新アメダスデータ積雪深をもとに、前回雪かきからの増減を算出
module SnowDepthHelper
  # 前回の雪かきからどれくらい積もったかを計算
  def snow_depth_since_last_work(user, station_number)
    # 最新のユーザー記録を取得
    latest_record = user.user_records
                        .where(station_number: station_number)
                        .order(created_at: :desc)
                        .first
    
    return nil unless latest_record

    # 最新のアメダスデータを取得
    latest_amedas = AmedasRecord.where(station_number: station_number)
                                .order(json_date: :desc)
                                .first
    
    return nil unless latest_amedas

    # 差分を計算
    current_depth = latest_amedas.snow
    last_work_depth = latest_record.end_snow_depth
    
    return nil unless current_depth && last_work_depth

    # マイナスの場合もそのまま差分を返す(高気温による融雪や自重による圧雪の可能性を考慮)
    difference = current_depth - last_work_depth

end

  # 差分を表示用にフォーマット
  def format_snow_depth_since_last_work(user, station_number)
    difference = snow_depth_since_last_work(user, station_number)
    
    return "データがありません" unless difference

    if difference > 0
      "前回の雪かきから#{difference}cm積もりました"
    elsif difference == 0
      "前回の雪かきから積雪の変化はありません"
    else
      "前回の雪かきから#{difference * -1}cm減りました"
    end
  end
end
