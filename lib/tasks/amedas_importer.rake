namespace :amedas do
  desc "アメダスデータを取得して保存する"
  task import: :environment do
    puts "[#{Time.current}] アメダスデータ取得開始"

    begin
      AmedasImportService.import_datetime

      puts "[#{Time.current}] アメダスデータ取得完了"
    rescue StandardError => e
      puts "[#{Time.current}] エラー発生: #{e.message}"
      puts e.backtrace.join("\n")

      # 本番環境ではエラー通知サービス(Sentry等)に送信
      raise e
    end
  end
end
