class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end

# database_authenticatable: データベースに保存されたパスワードが正しいか検証する
# registerable: ユーザー登録、編集、削除の機能を提供する
# recoverable: パスワードをリセットするための機能を提供する
# rememberable: ログイン状態を記憶するための機能を提供
# validatable: メールアドレスとパスワードのバリデーションを提供する
# lockable: 一定回数以上のログイン失敗でアカウントをロックする
# timeoutable: 一定時間操作がなければ自動的にログアウト
# trackable: ユーザーのサインイン回数、サインイン日時、IPアドレスなどの情報を追跡する機能を提供する
# omniauthable: OAuth認証を利用するための機能を提供する