class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @micropost  = current_user.microposts.build # フォーム用
      @feed_items = current_user.feed.paginate(page: params[:page]) # フィード表示用
    end
  end

  def help; end

  def about; end

  def contact; end
end
