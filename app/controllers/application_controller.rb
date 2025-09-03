# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :ensure_household_exists!, unless: :skip_household_check?

  # ログイン後のリダイレクト先を設定
  def after_sign_in_path_for(resource)
    dashboard_path
  end

  # ログアウト後のリダイレクト先を設定
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name profile_image])
  end

  def current_household
    @current_household ||= current_user&.households&.first
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
