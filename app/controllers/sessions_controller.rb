
class SessionsController < ApplicationController

  skip_before_action :require_login, only: [:new, :create]

  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:session][:email]&.downcase)

    if user&.authenticate(params[:session][:password])
      session[:user_id] = user.id
      flash[:notice] = "Bem-vindo, #{user.display_name}!"
      redirect_back_or(dashboard_path)
    else
      flash.now[:alert] = 'Email ou senha inválidos.'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = 'Você foi desconectado com sucesso.'
    redirect_to login_path
  end

  private

  def dashboard_path
    if current_user.admin?
      root_path
    else
      parking_lots_path
    end
  end
end
