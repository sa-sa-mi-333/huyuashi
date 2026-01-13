# サービスクラスから呼び出し データ更新時などに実行
namespace :station do
  desc "csvファイルから積雪観測地点のデータをインポートする"
  task import: :environment do
    SnowStationImporter.import
  end
end
