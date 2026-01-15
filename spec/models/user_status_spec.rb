# spec/models/user_status_spec.rb
require 'rails_helper'

RSpec.describe UserStatus, type: :model do
  describe 'バリデーション' do

    # station_numberはnilを許可 snow_station側で確認する

    # belongs_to:user
    it 'user_idがあれば有効' do
      user = User.create(email: 'valid_test@example.com', password: 'password')
      user_status = user.user_status
      expect(user_status).to be_valid
      expect(user_status.errors).to be_empty
    end

    it 'user_idがなければ無効' do
      expect {
        UserStatus.create!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  # Userモデル作成時にUserStatusモデルをコールバックで作成
  describe 'userモデル作成時にnameを受け取って設定する 未入力ならデフォルト名を設定' do
    context 'デフォルト名が適用される場合' do
      # name = blank
      it 'デフォルト値「名無しの雪だるま」が設定される' do
        user = User.create(email: 'blank_test@example.com', password: 'password', name: '')
        expect(user.user_status.name).to eq('名無しの雪だるま')
      end

      # name = nil
      it 'デフォルト値「名無しの雪だるま」が設定される' do
        user = User.create(email: 'nil_test@example.com', password: 'password')
        expect(user.user_status.name).to eq('名無しの雪だるま')
      end
    end

    # name = xxx
    context 'nameが指定されている場合' do
      it '指定されたnameが設定される' do
        user = User.create(email: 'add_name_test@example.com', password: 'password', name: '太郎')
        expect(user.user_status.name).to eq('太郎')
      end
    end
  end

  # default: 0, null: false
  describe 'station_statusをenum{ inactive: 0, active: 1 }で設定' do

    context 'action_statusがnilの場合' do
      it '「inactive」が設定される' do
        user = User.create(email: 'nilstatus_test@example.com', password: 'password', name: '太郎')
        expect(user.user_status.action_status).to eq('inactive')
      end
    end

    context 'enumキーが設定されている場合' do
      it '「inactive」なら有効' do
        user = User.create(email: 'inactive_test@example.com', password: 'password', name: '太郎')
        expect(user.user_status.action_status).to eq('inactive')
      end

      it '「active」なら有効' do
        user = User.create(email: 'active_test@example.com', password: 'password', name: '太郎')
        user.user_status.action_status = 'active'
        expect(user.user_status.action_status).to eq('active')
      end
    end

    context 'enumキー以外が設定されている場合' do
      it 'enumに設定されていない値は無効' do # enumの他の値にバリデーションを設定
        user = User.create(email: 'other_test@example.com', password: 'password', name: '太郎')
        user_status = UserStatus.create(user_id: user.id, action_status: :pending)
        expect(user_status).to be_invalid
      end
    end

    # action_statusのparamは設定されていないのでblankの場合は考慮しない

  end
end
