# 積雪深が計算できなかった雪かきレコードを再計算する
namespace :snow_depth do
  desc '未確定の積雪深をまとめて更新'
  task update_all: :environment do
    puts "===.積雪深の再計算を開始します ==="
    # 開始時積雪深の再計算
    # 終了時積雪深の再計算
    puts "===.積雪深の再計算が完了しました ==="
  end

  desc '未確定の開始時積雪深を更新'
  task update_start_snow_depth: :environment do
    # 開始積雪深が未確定のレコードを取得
    pending_records = UserRecord.where(start_snow_depth: nil)
                                .where.not(start_time: nil)
    puts "  開始時積雪深の保留件数: #{pending_record}件"
    pending_records.find_each do |record|
      # 再計算を試みる
      start_snow_depth = record.calculate_snow_depth(record.start_time)
      
      if start_snow_depth
        record.update(start_snow_depth: start_snow_depth)
        puts "  UserRecord #{record.id}: 開始時積雪深を更新しました (#{start_snow_depth}cm)"
      else
        puts "  UserRecord #{record.id}: まだ開始時積雪深を計算できません"
      end
    end
  end

  desc '未確定の終了時積雪深を更新'
  task update_end_snow_depth: :environment do
    # 終了時積雪深が未確定のレコードを取得
    pending_records = UserRecord.where(end_snow_depth: nil)
                                .where.not(end_time: nil)
    puts "  開始時積雪深の保留件数: #{pending_record}件"
    pending_records.find_each do |record|
      # 再計算を試みる
      end_snow_depth = record.calculate_snow_depth(record.end_time)
      
      if end_snow_depth
        record.update(end_snow_depth: end_snow_depth)
        puts "  UserRecord #{record.id}: 終了時積雪深を更新しました (#{end_snow_depth}cm)"
      else
        puts "  UserRecord #{record.id}: まだ終了時積雪深を計算できません"
      end
    end
  end
end
