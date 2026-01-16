# 積雪深が計算できなかった雪かきレコードを再計算する
namespace :user_records do
  desc "積雪深がnilのUserRecordを計算して保存"
  task calculate_snow_depths: :environment do
    # start_snow_depthがnilのレコードを取得
    UserRecord.where(start_snow_depth: nil).where.not(start_time: nil).find_each do |user_record|
      calculated_start = user_record.calculate_snow_depth(user_record.start_time)
      if calculated_start.present?
        user_record.update_column(:start_snow_depth, calculated_start)
        puts "UserRecord ##{user_record.id}: start_snow_depth = #{calculated_start}"
      end
    end
    
    # end_snow_depthがnilのレコードを取得
    UserRecord.where(end_snow_depth: nil).where.not(end_time: nil).find_each do |user_record|
      calculated_end = user_record.calculate_snow_depth(user_record.end_time)
      if calculated_end.present?
        user_record.update_column(:end_snow_depth, calculated_end)
        puts "UserRecord ##{user_record.id}: end_snow_depth = #{calculated_end}"
      end
    end
    
    puts "積雪深の計算が完了しました!"
  end
end
