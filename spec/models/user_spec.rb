# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'アソシエーション' do
    # has_one :user_status
    it 'UserStatusと1対1の関係を持つ' do
      association = described_class.reflect_on_association(:user_status)
      expect(association.macro).to eq(:has_one)
    end

    # dependent: :destroy
    it 'ユーザー削除時にUserStatusも削除される' do
      user = User.create(email: 'test@example.com', password: 'password')
      user_status_id = user.user_status.id
      user.destroy
      expect(UserStatus.find_by(id: user_status_id)).to be_nil
    end
  end

  describe 'コールバック' do
    #  after_create :create_user_status_record
    it 'ユーザー作成時にUserStatusも作成される' do
      expect {
        User.create(email: 'test@example.com', password: 'password')
      }.to change(UserStatus, :count).by(1)
    end

    # nameを受け取ってステータスレコードを作成する
    it 'nameを指定した場合、UserStatusのnameに反映される' do
      user = User.create(email: 'test@example.com', password: 'password', name: '太郎')
      expect(user.user_status.name).to eq('太郎')
    end
  end

  describe 'バリデーション' do
    # devise側のバリデーションが有効か確認
    it 'emailがありパスワードが6文字以上で有効' do
      user = User.create(email: 'test@example.com', password: 'password')
      expect(user).to be_valid
      expect(user.errors).to be_empty
    end

    it 'emailがなければ無効' do
      expect {
        User.create!(email: '', password: 'password')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'emailに@がなければ無効' do
      expect {
        User.create!(email: 'testexample.com', password: 'password')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'パスワードがなければ無効' do
      expect {
        User.create!(email: 'test@example.com', password: '')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'パスワードが6文字未満なら無効' do
      expect {
        User.create!(email: 'test@example.com', password: '12345')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
