class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    # params[:id]は有効化トークン
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user # sessionのへの書き込み
      flash[:success] = 'Account activated!'
      redirect_to user
    else
      flash[:danger] = 'Invalid activation link'
      redirect_to root_url
    end
  end
end
