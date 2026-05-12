class ChangeUsersCpfAndTelefoneToString < ActiveRecord::Migration[8.1]
  def change
    change_column :users, :cpf, :string
    change_column :users, :telefone, :string
  end
end
