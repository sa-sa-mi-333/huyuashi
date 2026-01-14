class UserRecord < ApplicationRecord
  belongs_to :user
  belongs_to :snow_station,
              foreign_key: :station_number,
              primary_key: :station_number

  # 開始時の積雪深を計算
  def calculate_snow_depth(time)
    calculate_snow_depth_at(start_time)
  end

  # 終了時の積雪深を計算
  def calculate_end_snow_depth
    # after_recordがない場合は一旦nilを返す
    snow_depth = calculate_snow_depth_at(end_time)

    # 補間計算ができなかった場合はnilを返す
    return nil unless depth
    depth
  end

  private
  
  def calculate_snow_depth_at(time)
    # timeがなければnilを返す
    return nil unless time
    # time以前の直近のレコードを探す
    before_record = AmedasRecord.where(station_number: station_number)
                                .where('recorded_at <= ?', time)
                                .order(recorded_at: :desc)
                                .first
    # time以降の直近のレコードを探す
    after_record = AmedasRecord.where(station_number: station_number)
                               .where('recorded_at > ?', time)
                               .order(recorded_at: :asc)
                               .first
    
    # 前後のレコードが揃っていれば補間計算を実施
    if before_record && after_record
      interpolate_snow_depth(before_record, after_record, time)
    # after_recordがない場合はnilを返す(後で再計算)
    elsif before_record && !after_record
      nil
    # before_recordがない場合はafter_recordの値を使用
    elsif !before_record && after_record
      after_record.snow_depth
    # どちらもない場合はnilを返す
    else
      nil
    end
  end

  def interpolate_snow_depth(before_record, after_record, time)
    # 2つのレコードの差分(時間単位)を秒数で求める
    total_seconds = (after_record.created_at - before_record.created_at).to_f
    # メソッドを実行した時間と、それ以前の直近レコードとの差分(分単位)を秒数で求める
    elapsed_seconds = (time - before_record.created_at).to_f
    # 初回積雪深の差分 後から取得したレコード - 直近レコード
    depth_diff = after_record.snow_depth - before_record.snow_depth
    # 小数点以下は丸め、積雪深をcm単位で返す
    (before_record.snow_depth + (depth_diff * elapsed_seconds / total_seconds)).round(0)
  end
end
