# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

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
end
