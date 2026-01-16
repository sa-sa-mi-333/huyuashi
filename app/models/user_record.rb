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

    # レコードがなければnilを返す
    return nil unless before_record && after_record

    # 常にアメダスデータから線形補間で計算
    interpolate_snow_depth(before_record, after_record, time)
  end

  private

  def interpolate_snow_depth(before_record, after_record, time)
    # before_recordの時刻
    before_time = AmedasRecord.json_date_to_time(before_record.json_date)
    # after_recordの時刻
    after_time = AmedasRecord.json_date_to_time(after_record.json_date)

    # 2つのレコードの時間差(分)
    total_minutes = ((after_time - before_time) / 60).to_f
    return before_record.snow if total_minutes.zero?

    # timeとbefore_recordの時間差(分)
    elapsed_minutes = ((time - before_time) / 60).to_f

    # 1分あたりの積雪増加量
    depth_per_minute = (after_record.snow - before_record.snow) / total_minutes

    # 補間した積雪深を計算
    interpolated_depth = before_record.snow + (depth_per_minute * elapsed_minutes)

    # 小数点以下を四捨五入して返す
    interpolated_depth.round(0)
  end

  def find_before_record(time)
    # timeより前の時刻のレコードを取得 json_dateを数値として比較する
    target_json_date = AmedasRecord.time_to_hourly_json_date(time)

    AmedasRecord.where(station_number: station_number)
                .where("json_date <= ?", target_json_date)
                .order(json_date: :desc)
                .first
  end

  def find_after_record(time)
    # timeより後の時刻のレコードを取得 json_dateを数値として比較する
    target_json_date = AmedasRecord.time_to_hourly_json_date(time)

    AmedasRecord.where(station_number: station_number)
                .where("json_date > ?", target_json_date)
                .order(json_date: :asc)
                .first
  end
end
