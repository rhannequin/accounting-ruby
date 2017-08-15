class AddSlugToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :slug, :string, unique: true, index: true
  end
end
