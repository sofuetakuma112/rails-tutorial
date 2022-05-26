class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        # sessionにuserIdを書き込む
        log_in user
        # app/helpers/sessions_helper.rbのrememberヘルパーメソッドを呼ぶ
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user # user_url(user)と等価
      else
        message  = 'Account not activated. '
        message += 'Check your email for the activation link.'
        flash[:warning] = message
        redirect_to root_url
      end
    else
      # nowでレンダリングが終わっているページで特別にフラッシュメッセージを表示する
      # flashは2回アクセスしたら消える？(リダイレクトを内、1回のアクセスとした場合)
      # flash.nowのメッセージはその後リクエストが発生したときに消滅します
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in? # current_userがnilではない場合のみlog_outを実行する
    redirect_to root_url
  end
end
