# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :ensure_household_exists!, unless: :skip_household_check?

  # ログイン後のリダイレクト先を設定
  def after_sign_in_path_for(_resource)
    # 招待トークンがある場合は招待受け入れページにリダイレクト
    if session[:invitation_token]
      invitation_path(session[:invitation_token])
    else
      dashboard_path
    end
  end

  # ログアウト後のリダイレクト先を設定
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name profile_image])
  end

  def current_household
    @current_household ||= begin
      return nil unless current_user
      
      # セッションに保存された世帯IDから取得
      if session[:household_id]
        current_user.households.find_by(id: session[:household_id])
      else
        # セッションにない場合は最初の世帯を取得し、セッションに保存
        household = current_user.households.first
        session[:household_id] = household&.id
        household
      end
    end
  end
  helper_method :current_household

  def ensure_household_exists!
    return if current_household

    redirect_to new_household_path, alert: '世帯を作成してください。'
  end

  def skip_household_check?
    # HouseholdsControllerのnewとcreateアクションでは世帯チェックをスキップ
    # Deviseのコントローラーでも世帯チェックをスキップ
    (controller_name == 'households' && action_name.in?(%w[new create])) ||
      devise_controller?
  end
end
