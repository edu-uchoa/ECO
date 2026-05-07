class AddRoleToUsersAndCreateModerationLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string, default: "common", null: false
    add_index :users, :role

    create_table :moderation_logs do |t|
      t.references :collection_point, null: false, foreign_key: true
      t.references :moderator, null: false, foreign_key: { to_table: :users }
      t.string :action_type, null: false
      t.string :previous_status
      t.string :new_status
      t.text :reason

      t.timestamps
    end

    add_index :moderation_logs, :action_type
    add_index :moderation_logs, :created_at
  end
end
