class UserRecord < ApplicationRecord
  belongs_to :user
  belongs_to :snow_station,
              foreign_key: :station_number,
              primary_key: :station_number

  # 積雪深を計算
  def calculate_snow_depth(time)
    # 積雪深算出用レコードを準備
    before_record = find_before_record(time)
    after_record = find_after_record(time)
    previous_record = previous_user_record

    # レコードがなければnilを返す
    return nil unless before_record && after_record

    # 初回の計算方法と2回目以降の計算方法が異なるため分岐
    if previous_record.nil? || previous_record.end_snow_depth.nil?
      # 初回雪かきレコードの補間積雪深算出
      first_snow_depth(before_record, after_record, time)
    else
      # 2回目以降の雪かきレコードの補間積雪深算出
      subsequent_snow_depth(before_record, after_record, time, previous_user_record)
    end
  end

  private


  def first_snow_depth(before_record, after_record, time)
    # 2つのレコードの差分(時間単位)を秒数で求める
    total_seconds = ((after_record.created_at - before_record.created_at)/3600).ceil * 3600
    return before_record.snow if total_seconds.zero?
    # メソッドを実行した時間と、それ以前の直近レコードとの差分(分単位)を秒数で求める
    elapsed_seconds = ((time - before_record.created_at)/60).ceil * 60
    # 1時間あたりの積雪深：後から取得したレコード - 直近レコード
    depth_diff = after_record.snow - before_record.snow

    # 初回雪かきの積雪深：アメダスレコードの値+XX分の積雪増加分 小数点以下は丸め、積雪深をcm単位で返す
    (before_record.snow + (depth_diff * elapsed_seconds / total_seconds).round(0))
  end

  def subsequent_snow_depth(before_record, after_record, time, previous_record)
    # 2つのレコードの差分(時間単位)を秒数で求める
    total_seconds = ((after_record.created_at - before_record.created_at)/3600).ceil * 3600
    return previous_record.end_snow_depth if total_seconds.zero?
    # メソッドを実行した時間と、それ以前の直近レコードとの差分(分単位)を秒数で求める
    elapsed_seconds = ((time - before_record.created_at)/60).ceil * 60
    # 1時間あたりの積雪深：後から取得したレコード - 直近レコード
    depth_diff = after_record.snow - before_record.snow
    # 2回目以降雪かきの積雪深：前回雪かきレコードの値+XX分の積雪増加分 小数点以下は丸め、積雪深をcm単位で返す
    (previous_record.end_snow_depth + (depth_diff * elapsed_seconds / total_seconds)).round(0)
  end

  def find_before_record(time)
    # time以前の直近のレコードを取得する
    before_record = AmedasRecord.where(station_number: station_number)
                                .where('created_at <= ?', time)
                                .order(created_at: :desc)
                                .first
  end

  def find_after_record(time)
    # time以降の直近のレコードを取得する
    after_record = AmedasRecord.where(station_number: station_number)
                                .where('created_at > ?', time)
                                .order(created_at: :asc)
                                .first
  end

  def previous_user_record
    # 直近のuser_recordを取得する
    UserRecord.where(user_id: user_id)
              .where(station_number: station_number)
              .where('created_at < ?', created_at || Time.current)
              .order(created_at: :desc)
              .first
  end
end
