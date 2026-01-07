class HomeController < ApplicationController
  # ログイン後のみ
  before_action :authenticate_user!

  def top
    @test = "homeコントローラーで設定しました"
  end
end
