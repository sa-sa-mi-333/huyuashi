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
      user = create(:user)
      user_status_id = user.user_status.id
      user.destroy
      expect(UserStatus.find_by(id: user_status_id)).to be_nil
    end
  end

  describe 'コールバック' do
    #  after_create :create_user_status_record
    it 'ユーザー作成時にUserStatusも作成される' do
      expect {
        create(:user)
      }.to change(UserStatus, :count).by(1)
    end

    # nameを受け取ってステータスレコードを作成する
    it 'nameを指定した場合、UserStatusのnameに反映される' do
      user = create(:user, :with_name, user_name: '太郎')
      expect(user.user_status.name).to eq('太郎')
    end

    it 'nameを指定しない場合、UserStatusにデフォルト名が反映される' do
      user = create(:user)
      expect(user.user_status.name).to eq('名無しの雪だるま')
    end
  end

  describe 'バリデーション' do
    # devise側のバリデーションが有効か確認
    it 'emailがありパスワードが6文字以上で有効' do
      user = build(:user)
      expect(user).to be_valid
      expect(user.errors).to be_empty
    end

    it 'emailが重複していれば無効' do
      user = create(:user)
      user_duplicated = build(:user, email: user.email)
      expect {
        user_duplicated.save!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'emailがなければ無効' do
      user = build(:user, email: nil)
      expect {
        user.save!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'emailに@がなければ無効' do
      user = build(:user, email: 'testexample.com')
      expect {
        user.save!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'パスワードがなければ無効' do
      user = build(:user, password: nil)
      expect {
        user.save!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'パスワードが6文字未満なら無効' do
      user = build(:user, password: '12345')
      expect {
        user.save!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
