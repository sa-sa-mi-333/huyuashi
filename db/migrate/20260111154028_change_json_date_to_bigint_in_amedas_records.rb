class ChangeJsonDateToBigintInAmedasRecords < ActiveRecord::Migration[8.0]
  def up
    # 既存のデータを削除(型変更のため)
    AmedasRecord.delete_all

    # json_dateカラムをbigintに変更(yyyymmddhh0000の形式で数値を保存するため)
    change_column :amedas_records, :json_date, :bigint
  end

#  def down
#    # ロールバック時の処理
#    change_column :amedas_records, :json_date, :integer
#  end
end
