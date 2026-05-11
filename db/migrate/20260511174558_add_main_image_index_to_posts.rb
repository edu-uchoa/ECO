class AddMainImageIndexToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :main_image_index, :integer, default: 0, null: false
  end
end
