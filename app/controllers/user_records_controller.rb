class UserRecordsController < ApplicationController
  # ログイン後のみ
  before_action :authenticate_user!

  def new
  end

  def create
  end

  def update
  end

  def index
  end
end
