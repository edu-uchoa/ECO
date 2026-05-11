class CreatePostClaims < ActiveRecord::Migration[8.1]
  def change
    create_table :post_claims do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :post_claims, [:post_id, :user_id], unique: true
  end
end
