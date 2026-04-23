class AddPostIdToMessages < ActiveRecord::Migration[8.1]
  def change
    add_reference :messages, :post, null: true, foreign_key: true
  end
end
