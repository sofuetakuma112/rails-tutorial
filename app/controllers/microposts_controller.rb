class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i[create destroy]
  before_action :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    # attachメソッドで新たに作成したmicropostオブジェクトに画像を追加する
    @micropost.image.attach(params[:micropost][:image]) # この行で画像のアップロードを行っている？
    if @micropost.save
      flash[:success] = 'Micropost created!'
      redirect_to root_url
    else
      # @feed_itemsを再度宣言しないと@feed_itemsがnilになる
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = 'Micropost deleted'
    # request.referrerは一つ前のURLを返します
    # マイクロポストがHomeページから削除された場合でも
    # プロフィールページから削除された場合でも、
    # request.referrerを使うことで
    # DELETEリクエストが発行されたページに戻すことができる
    redirect_to request.referrer || root_url
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :image)
  end

  # 削除対象のマイクロポストが現在ログインしているユーザーの所有かチェック
  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_url if @micropost.nil?
  end
end
