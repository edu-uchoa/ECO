class CreateCollectionPoints < ActiveRecord::Migration[8.1]
  def change
    create_table :collection_points do |t|
      t.string :name
      t.decimal :latitude
      t.decimal :longitude
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
