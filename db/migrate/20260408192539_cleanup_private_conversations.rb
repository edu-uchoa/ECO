class CleanupPrivateConversations < ActiveRecord::Migration[8.1]
  def change
    drop_table :private_messages, if_exists: true
    drop_table :private_conversations, if_exists: true
  end
end
