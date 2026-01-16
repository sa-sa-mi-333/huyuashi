# spec/models/amedas_record_spec.rb
require 'rails_helper'

RSpec.describe AmedasRecord, type: :model do
  describe 'アソシエーション' do
    it 'SnowStationと多対1の関係を持つ' do
      association = described_class.reflect_on_association(:snow_station)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe 'バリデーション' do
    it '必須項目があれば有効' do
      amedas_record = build(:amedas_record)
      expect(amedas_record).to be_valid
      expect(amedas_record.errors).to be_empty
    end

    it 'station_numberが紐づいていなければ無効' do
      amedas_record = build(:amedas_record, station_number: nil)
      expect(amedas_record).to be_invalid
    end

    it 'json_dateがなければ無効' do
      amedas_record = build(:amedas_record, json_date: nil)
      expect(amedas_record).to be_invalid
    end

    it 'created_atがなければ無効' do
      amedas_record = build(:amedas_record, created_at: nil)
      expect(amedas_record).to be_invalid
    end

    it 'updated_atがなければ無効' do
      amedas_record = build(:amedas_record, updated_at: nil)
      expect(amedas_record).to be_invalid
    end
  end

  describe 'データの作成' do
    it '複数のAmedasRecordが同じSnowStationに紐づけられる' do
      snow_station = create(:snow_station)

      expect {
        create(:amedas_record, :at_time,
              snow_station: snow_station,
              time: Time.zone.parse('2025-10-10 00:00:00'))
        create(:amedas_record, :at_time,
              snow_station: snow_station,
              time: Time.zone.parse('2026-01-01 00:00:00'))
      }.to change(snow_station.amedas_records, :count).by(2)
    end
  end

  describe 'ヘルパーメソッド' do
    context '.time_to_hourly_json_date' do
      it '時刻を00分00秒に丸める' do
        # 13:45:30 → 13:00:00
        time = Time.zone.parse('2026-01-15 13:45:30')
        json_date = AmedasRecord.time_to_hourly_json_date(time)

        expect(json_date).to eq(20260115130000)
      end

      it '既に00分00秒の場合はそのまま' do
        time = Time.zone.parse('2026-01-15 13:00:00')
        json_date = AmedasRecord.time_to_hourly_json_date(time)

        expect(json_date).to eq(20260115130000)
      end
    end

    context '.json_date_to_time' do
      it 'json_dateをtime形式に変換する' do
        # 2026/01/23 → 04:56:07 JST
        json_date = 20260123045607
        result = AmedasRecord.json_date_to_time(json_date)

        # Time型同士で比較
        expect(result).to eq(Time.zone.parse('2026-01-23 04:56:07'))
      end
    end
  end
end
