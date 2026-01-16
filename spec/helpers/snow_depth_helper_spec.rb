# spec/helpers/snow_depth_helper_spec.rb
require 'rails_helper'

RSpec.describe SnowDepthHelper, type: :helper do
  describe '#snow_depth_since_last_work' do
    let(:user) { create(:user) }
    let(:snow_station) { create(:snow_station) }
    let(:station_number) { snow_station.station_number }
    let(:current_time) { Time.zone.parse('2025-01-15 15:00:00') }

    context '前回の雪かき記録とアメダスデータが存在する場合' do
      let!(:user_record) do
        create(:user_record,
          user: user,
          snow_station: snow_station,
          station_number: station_number,
          end_snow_depth: 35,
          created_at: 1.hour.ago
        )
      end
      
      let!(:latest_amedas) do
        create(:amedas_record, :at_time,
          snow_station: snow_station,
          station_number: station_number,
          snow: 40,
          time: current_time
        )
      end
      
      it '積雪の差分を返す' do
        expect(helper.snow_depth_since_last_work(user, station_number)).to eq(5)
      end
    end
    
    context '積雪が減っている場合（マイナス）' do
      let!(:user_record) do
        create(:user_record,
          user: user,
          station_number: station_number,
          end_snow_depth: 40,
          created_at: 1.hour.ago
        )
      end
      
      let!(:latest_amedas) do
        create(:amedas_record,
          station_number: station_number,
          snow: 35,
          json_date: Time.current.strftime('%Y%m%d%H%M%S')
        )
      end
      
      it 'マイナスの値を返す' do
        expect(helper.snow_depth_since_last_work(user, station_number)).to eq(-5)
      end
    end
    
    context '前回の雪かき記録が存在しない場合' do
      it 'nilを返す' do
        expect(helper.snow_depth_since_last_work(user, station_number)).to be_nil
      end
    end
    
    context 'アメダスデータが存在しない場合' do
      let!(:user_record) do
        create(:user_record,
          user: user,
          station_number: station_number,
          end_snow_depth: 35
        )
      end
      
      it 'nilを返す' do
        expect(helper.snow_depth_since_last_work(user, station_number)).to be_nil
      end
    end
    
    context '積雪データがnullの場合' do
      let!(:user_record) do
        create(:user_record,
          user: user,
          station_number: station_number,
          end_snow_depth: nil
        )
      end
      
      let!(:latest_amedas) do
        create(:amedas_record,
          station_number: station_number,
          snow: 40,
          json_date: Time.current.strftime('%Y%m%d%H%M%S')
        )
      end
      
      it 'nilを返す' do
        expect(helper.snow_depth_since_last_work(user, station_number)).to be_nil
      end
    end
  end
  
  describe '#format_snow_depth_since_last_work' do
    let(:user) { create(:user) }
    let(:station_number) { '0010' }
    
    context '差分が正の値の場合' do
      before do
        allow(helper).to receive(:snow_depth_since_last_work)
          .with(user, station_number)
          .and_return(5)
      end
      
      it '積雪増加のメッセージを返す' do
        expect(helper.format_snow_depth_since_last_work(user, station_number))
          .to eq('前回の雪かきから5cm積もりました')
      end
    end
    
    context '差分が負の値の場合' do
      before do
        allow(helper).to receive(:snow_depth_since_last_work)
          .with(user, station_number)
          .and_return(-3)
      end
      
      it '積雪減少のメッセージを返す' do
        expect(helper.format_snow_depth_since_last_work(user, station_number))
          .to eq('前回の雪かきから3cm減りました')
      end
    end
    
    context '差分が0の場合' do
      before do
        allow(helper).to receive(:snow_depth_since_last_work)
          .with(user, station_number)
          .and_return(0)
      end
      
      it '変化なしのメッセージを返す' do
        expect(helper.format_snow_depth_since_last_work(user, station_number))
          .to eq('前回の雪かきから積雪の変化はありません')
      end
    end
    
    context 'データが存在しない場合' do
      before do
        allow(helper).to receive(:snow_depth_since_last_work)
          .with(user, station_number)
          .and_return(nil)
      end
      
      it 'データなしのメッセージを返す' do
        expect(helper.format_snow_depth_since_last_work(user, station_number))
          .to eq('データがありません')
      end
    end
  end
end