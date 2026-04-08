class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :cpf, :integer
    add_column :users, :telefone, :integer
    add_column :users, :uf, :string
    add_column :users, :cidade, :string
  end
end
