class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # ログイン後の場合分け
  def after_sign_in_path_for(resource)
    if resource.user_status&.station_number.present?
        authenticated_root_path
    else
        select_station_user_status_path
    end
  end

  # アクション前に確認 devise関連画面でデバイス用のストロングパラメータを参照する
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # devise用ストロングパラメータの設定 sign_up時にnameカラムキーを追加する
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end
end
