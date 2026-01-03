# spec/models/user_status_spec.rb
require 'rails_helper'

RSpec.describe UserStatus, type: :model do
  describe 'バリデーション' do
    # belongs_to:user
    it 'user_idがあれば有効' do
      user = User.create(email: 'test@example.com', password: 'password')
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

  # t.string "name", default: "名無しの雪だるま"
  describe 'nameがあれば入力内容を、未入力ならデフォルト名を設定' do
    # name=  blank
    context 'nameが空の場合' do
      it 'デフォルト値「名無しの雪だるま」が設定される' do
        user = User.create(email: 'test@example.com', password: 'password', name: '')
        expect(user.user_status.name).to eq('名無しの雪だるま')
      end
    end

    # name = nil
    context 'nameがnilの場合' do
      it 'デフォルト値「名無しの雪だるま」が設定される' do
        user = User.create(email: 'test@example.com', password: 'password')
        expect(user.user_status.name).to eq('名無しの雪だるま')
      end
    end

    # name = xxx
    context 'nameが指定されている場合' do
      it '指定されたnameが設定される' do
        user = User.create(email: 'test@example.com', password: 'password', name: '太郎')
        expect(user.user_status.name).to eq('太郎')
      end
    end
  end
end
