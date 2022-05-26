module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # 記憶トークンcookieに対応するユーザーを返す
  # 永続セッションの場合は、
  # session[:user_id]が存在すれば一時セッションからユーザーを取り出し、
  # それ以外の場合はcookies[:user_id]からユーザーを取り出して、
  # 対応する永続セッションにログインする
  # ビューからcurrent_userにアクセスできるようにするためにヘルパーメソッドとして定義
  # 全ての条件式でfalseになった場合はnilを返すのが正常
  def current_user
    if (user_id = session[:user_id])
      # @current_userがfalsyな場合にのみ
      # User.find_by(id: session[:user_id])を評価して代入する
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember # Userモデルのrememberメソッドを呼び出す(ここで記憶トークンを作成してUserモデルの属性に値をセットして、暗号化した記憶トークンをDBに保存している)
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 永続的セッションを破棄する
  # rememberと逆のことをする
  def forget(user)
    user.forget # DBから暗号化された記憶トークンを削除している
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil # リダイレクトすればインスタンス変数は再定義され自動的にnilになるので、この行の処理はリダイレクトせずrenderメソッド等でレンダリングする場合にのみ発生する問題に対応している
  end

  # 渡されたユーザーがカレントユーザーであればtrueを返す
  def current_user?(user)
    user && user == current_user
  end

  # 記憶したURL（もしくはデフォルト値）にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  # ログインしていないユーザーが保護されたページにログイン後リダイレクトされるために記憶する
  def store_location
    # request.original_urlでリクエスト先が取得できます
    # GETリクエストが送られたときだけ格納するようにしておきます
    # これによって、
    # 例えばログインしていないユーザーがフォームを使って送信した場合、
    # 転送先のURLを保存させないようにできます。
    session[:forwarding_url] = request.original_url if request.get?
  end
end
