class UsersController < ApplicationController
  before_action :logged_in_user, only: %i[index edit update destroy]
  before_action :correct_user,   only: %i[edit update]
  before_action :admin_user,     only: :destroy

  def index
    # params[:page]はwill_paginateによって自動的に生成されます。
    @users = User.paginate(page: params[:page])
  end

  def show
    # params[:id]は文字列型の"1"ですが、findメソッドでは自動的に整数型に変換されます。
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    # debugger # byebug gemによるdebuggerメソッド
  end

  def new
    @user = User.new
  end

  def create
    # user_params => {"name"=>"", "email"=>"", "password"=>"", "password_confirmation"=>""}
    @user = User.new(user_params) # 実装は終わっていないことに注意!
    if @user.save
      @user.send_activation_email
      flash[:info] = 'Please check your email to activate your account.'
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User deleted'
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  # 正しいユーザーかどうか確認
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  # 管理者かどうか確認
  def admin_user
    # logged_in_userでログイン済みであることは確認済みなので
    # current_userはnilにはならない
    redirect_to(root_url) unless current_user.admin?
  end
end
