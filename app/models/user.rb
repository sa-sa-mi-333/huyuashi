class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, # データベースに保存されたパスワードが正しいか検証
         :registerable, # ユーザー登録、編集、削除機能
         :recoverable, # パスワードをリセット機能
         :rememberable, # ログイン状態記憶機能
         :validatable # メールアドレスとパスワードのバリデーションチェック

  # ユーザーに対してステータスを1つ紐付け
  has_one :user_status, dependent: :destroy
  # ユーザーに対してレコードは複数
  has_many :user_records, dependent: :destroy
  # 入力フォーム用に仮想属性を設定 userレコード作成と同時にnameも設定する
  attr_accessor :name
  # ユーザー作成後、ステータスレコードを作成する
  after_create :create_user_status_record

  private
  # nameを受け取ってステータスレコードを作成する
  def create_user_status_record
    create_user_status(name: name, action_status: :inactive)
  end
end

# deviseその他機能
# lockable: 一定回数以上のログイン失敗でアカウントをロックする
# timeoutable: 一定時間操作がなければ自動的にログアウト
# trackable: ユーザーのサインイン回数、サインイン日時、IPアドレスなどの情報を追跡する機能を提供する
# omniauthable: OAuth認証を利用するための機能を提供する
