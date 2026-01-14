class ChangeJsonDateToBigintInAmedasRecords < ActiveRecord::Migration[8.0]
  def up
    # 既存のデータを削除(型変更のため)
    AmedasRecord.delete_all

    # json_dateカラムをbigintに変更(yyyymmddhh0000の形式で数値を保存するため)
    change_column :amedas_records, :json_date, :bigint
  end

  #  def down
  #    # インデックスが存在する場合のみ削除
  #    if index_exists?(:amedas_records, :station_number)
  #      remove_index :amedas_records, :station_number
  #    end
  #
  #    remove_reference :amedas_records, :snow_station, foreign_key: true
  #  end
end
