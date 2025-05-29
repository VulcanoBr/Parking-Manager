# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base

  include Pundit::Authorization

  protect_from_forgery with: :exception

  before_action :require_login

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized(exception)
    flash[:alert] = "Você não tem permissão para realizar esta ação."
    redirect_back(fallback_location: root_path)
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
    nil
  end

  def logged_in?
    !!current_user
  end

  def require_login
    unless logged_in?
      store_location
      flash[:alert] = 'Você precisa estar logado para acessar esta página.'
      redirect_to login_path
    end
  end

  def require_admin
    unless current_user&.admin?
      flash[:alert] = 'Acesso negado. Apenas administradores podem acessar esta página.'
      redirect_to parking_lots_path
    end
  end

  def store_location
    session[:return_to] = request.original_url if request.get? && !request.xhr?
  end

  def redirect_back_or(default)
    redirect_to(session.delete(:return_to) || default)
  end

  def skip_authentication
    # Método para controllers que não precisam de autenticação
  end

  helper_method :current_user, :logged_in?
end
