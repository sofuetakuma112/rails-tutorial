class CreateMicroposts < ActiveRecord::Migration[6.0]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true # usersテーブルへの参照を作る

      t.timestamps
    end
    # user_idに関連付けられたすべてのマイクロポストを
    # 作成時刻の逆順で取り出しやすくなります。
    # 両方のキーを同時に扱う複合キーインデックスを作成します。
    add_index :microposts, %i[user_id created_at]
  end
end
