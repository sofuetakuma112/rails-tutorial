require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout links" do
    get root_path
    # assert_は引数と等しいかを検証するメソッド群？
    assert_template 'static_pages/home' # レンダリングすべきテンプレートがレンダリングできているかアサートしている？
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path # Railsは自動的にはてなマーク "?" をabout_pathに置換しています
    assert_select "a[href=?]", contact_path
  end
end
