class CreatePrivateConversationsAndFixMessages < ActiveRecord::Migration[8.1]
  def change
    # Drop old broken tables
    drop_table :messages, if_exists: true
    drop_table :conversations, if_exists: true

    create_table :private_conversations do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :private_conversations, [:sender_id, :receiver_id], unique: true

    create_table :messages do |t|
      t.text :content, null: false
      t.references :user, null: false, foreign_key: true
      t.references :private_conversation, null: false, foreign_key: true
      t.timestamps
    end
  end
end
