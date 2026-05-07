class ExpandCollectionPointsForModeration < ActiveRecord::Migration[8.1]
  def change
    add_column :collection_points, :title, :string
    add_column :collection_points, :description, :text
    add_column :collection_points, :address, :string
    add_column :collection_points, :opening_hours, :string
    add_column :collection_points, :categories, :text, default: "[]", null: false
    add_column :collection_points, :status, :string, default: "pending", null: false
    add_column :collection_points, :approved_by, :integer
    add_column :collection_points, :approved_at, :datetime
    add_column :collection_points, :rejection_reason, :text
    add_column :collection_points, :contact_name, :string
    add_column :collection_points, :contact_phone, :string
    add_column :collection_points, :contact_email, :string

    add_index :collection_points, :status
    add_index :collection_points, :approved_by

    add_foreign_key :collection_points, :users, column: :approved_by

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE collection_points
          SET
            title = COALESCE(NULLIF(name, ''), 'Ponto de coleta'),
            address = COALESCE(NULLIF(name, ''), 'Endereço não informado'),
            status = 'approved'
        SQL
      end
    end
  end
end
