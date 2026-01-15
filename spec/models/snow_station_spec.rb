# spec/models/snow_station_spec.rb
require 'rails_helper'

RSpec.describe SnowStation, type: :model do
  describe 'アソシエーション' do
    it 'AmedasRecordと1対多の関係を持つ' do
      association = described_class.reflect_on_association(:amedas_records)
      expect(association.macro).to eq(:has_many)
    end

    it 'snow_station削除時にAmedasRecordも削除される' do
      snow_station = create(:snow_station)
      # station_numberは自動的に一致するように設定される
      amedas_record = create(:amedas_record, snow_station: snow_station)

      expect {
        snow_station.destroy
      }.to change(AmedasRecord, :count).by(-1)

      # station_numberで検索
      expect(AmedasRecord.find_by(station_number: snow_station.station_number)).to be_nil
    end

    it '複数のAmedasRecordが同じstation_numberで紐づく' do
      snow_station = create(:snow_station)

      amedas_record1 = create(:amedas_record,
                              snow_station: snow_station,
                              json_date: 20250111110000)
      amedas_record2 = create(:amedas_record,
                              snow_station: snow_station,
                              json_date: 20260111110000)

      expect(snow_station.amedas_records.count).to eq(2)
      expect(amedas_record1.station_number).to eq(snow_station.station_number)
      expect(amedas_record2.station_number).to eq(snow_station.station_number)
    end
  end

  describe 'バリデーション' do
    it '必須項目があれば有効' do
      snow_station = build(:snow_station)
      expect(snow_station).to be_valid
      expect(snow_station.errors).to be_empty
    end

    it '観測所番号が重複していれば無効' do
      existing_station = create(:snow_station)
      duplicate_station = build(:snow_station, station_number: existing_station.station_number)

      expect(duplicate_station).not_to be_valid
      expect(duplicate_station.errors[:station_number]).to be_present
    end

    # DB制約のテスト(uniqueness制約)
    it '観測所番号の重複でActiveRecord::RecordNotUniqueが発生する' do
      existing_station = create(:snow_station)
      duplicate_station = build(:snow_station, station_number: existing_station.station_number)

      # バリデーションをスキップして保存を試みる
      expect {
        duplicate_station.save(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    # 必須項目のテスト(もしモデルにバリデーションがあれば)
    it '観測所番号がなければ無効' do
      snow_station = build(:snow_station, station_number: nil)
      expect(snow_station).not_to be_valid
      expect(snow_station.errors[:station_number]).to be_present
    end

    it '都府県振興局がなければ無効' do
      snow_station = build(:snow_station, prefecture: nil)
      expect(snow_station).not_to be_valid
      expect(snow_station.errors[:prefecture]).to be_present
    end

    it '観測所名がなければ無効' do
      snow_station = build(:snow_station, station_name: nil)
      expect(snow_station).not_to be_valid
      expect(snow_station.errors[:station_name]).to be_present
    end
  end
end
