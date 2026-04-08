class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.string :category, null: false
      t.string :location, null: false
      t.string :condition, null: false

      t.timestamps
    end

    add_index :posts, [:user_id, :created_at]
  end
end
