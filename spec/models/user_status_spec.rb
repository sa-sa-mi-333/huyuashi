# spec/models/user_status_spec.rb
require 'rails_helper'

RSpec.describe UserStatus, type: :model do
  describe 'バリデーション' do

    # station_numberはnilを許可 snow_station側で確認する

    # belongs_to:user
    it 'user_idがあれば有効' do
      user = create(:user)
      expect(user.user_status).to be_valid
      expect(user.user_status.errors).to be_empty
    end

    it 'user_idがなければ無効' do
      user_status = build(:user_status, user_id: nil)
      expect {
        user_status.save!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  # コールバックのnameチェックはuserモデル側で実施

  # default: 0, null: false
  describe 'station_statusのenum設定' do

    context 'action_statusが未設定の場合' do
      it '「inactive」が設定される' do
        user_status = build(:user_status)
        expect(user_status.action_status).to eq('inactive')
      end
    end

    context 'enumキーが設定されている場合' do
      it '「inactive」なら有効' do
        user_status = build(:user_status, action_status: 'inactive')
        expect(user_status.action_status).to eq('inactive')
      end

      it '「active」なら有効' do
        user_status = build(:user_status, action_status: 'active')
        expect(user_status.action_status).to eq('active')
      end
    end

    context 'enumキー以外が設定されている場合' do
      it 'enumに設定されていない値は無効' do # enumの他の値にバリデーションを設定
        user_status = build(:user_status, action_status: 'pending')
        expect {
          user_status.save!
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
