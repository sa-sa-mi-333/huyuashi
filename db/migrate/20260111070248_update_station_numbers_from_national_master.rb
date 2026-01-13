# station_numberとprefevtureを全国のアメダスマスターの内容に置き換える
class UpdateStationNumbersFromNationalMaster < ActiveRecord::Migration[8.0]
  def up
    SnowStationImporter.import
  end

  def down
    # 更新はrakeファイルを実行してください
    raise ActiveRecord::IrreversibleMigration,
    "観測所番号の更新は元に戻せません"
  end
end
