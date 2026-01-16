# spec/models/user_record_spec.rb
require 'rails_helper'

RSpec.describe UserRecord, type: :model do
  describe '初回雪かきレコード作成' do
    let(:user) { create(:user) }
    let(:snow_station) { create(:snow_station) }
    let(:station_number) { snow_station.station_number }
    let(:current_time) { Time.zone.parse('2025-01-15 15:00:00') }

    context '積雪深を補完して取得' do
    # テストデータの時刻を定義
    let(:time_13_00) { Time.zone.parse('2026-01-15 13:00:00') }
    let(:time_13_30) { Time.zone.parse('2026-01-15 13:30:00') }
    let(:time_14_00) { Time.zone.parse('2026-01-15 14:00:00') }
    let(:time_14_45) { Time.zone.parse('2026-01-15 14:45:00') }
    let(:time_15_00) { Time.zone.parse('2026-01-15 15:00:00') }

    # 事前にamedas_recordを作成 13時に30cm、14時に40cm、15時に60cmを観測したとする
    let!(:amedas_record_13_00) do
      create(:amedas_record, :at_time,
             snow_station: snow_station,
             station_number: station_number,
             time: time_13_00,
             snow: 30)
    end

    let!(:amedas_record_14_00) do
      create(:amedas_record, :at_time,
             snow_station: snow_station,
             station_number: station_number,
             time: time_14_00,
             snow: 40)
    end

    let!(:amedas_record_15_00) do
      create(:amedas_record, :at_time,
             snow_station: snow_station,
             station_number: station_number,
             time: time_15_00,
             snow: 60)
    end

      it 'start_snow_depthが正しく計算される' do # 13:30 - 14:45 の間で雪かきを実施した想定
        # user_recordを作成
        user_record = create(:user_record,
                            user: user,
                            snow_station: snow_station,
                            station_number: station_number,
                            start_time: time_13_30)

        # モデル内のメソッドを呼び出して計算し保存する(実際には定時処理のタイミングでrakeファイル経由で実行)
        # 13:30の積雪深: 14時の積雪深 - { 13~14時の間の積雪深増加量 * start_timeのminute } で求める
        # 40cm - {(40cm - 30cm) / 60minute} * 35minite = 40 - {10 * (30 / 60 )} = 35
        user_record.start_snow_depth = user_record.calculate_snow_depth(user_record.start_time)
        user_record.save!
        expect(user_record.start_snow_depth).to eq(35)
      end

      it 'end_snow_depthが正しく計算される' do
        # 13:30 - 14:45 の雪かきを実施した想定
        user_record = create(:user_record,
                            user: user,
                            snow_station: snow_station,
                            station_number: station_number,
                            end_time: time_14_45)

        # モデル内のメソッドを呼び出して計算 保存する 実際には定時処理のタイミングでrakeファイル経由で実行
        # 14:45の積雪深: 15時の積雪深 - { 14~15時の間の積雪深増加量 * end_timeのminute } で求める
        # 60cm - {(60cm - 40cm) / 60minute} * 45minite = 60 - {20 * (45 / 60 )} = 55
        user_record.end_snow_depth = user_record.calculate_snow_depth(user_record.end_time)
        user_record.save!

        expect(user_record.end_snow_depth).to eq(55)
      end
    end
  end
end
