class AddUsernameToUsers < ActiveRecord::Migration[8.1]
  def up
    # Fix duplicate names before adding unique index
    execute <<-SQL
      UPDATE users
      SET name = name || '_' || id
      WHERE id NOT IN (
        SELECT MIN(id) FROM users GROUP BY name
      )
    SQL

    add_index :users, :name, unique: true
  end

  def down
    remove_index :users, :name
  end
end
