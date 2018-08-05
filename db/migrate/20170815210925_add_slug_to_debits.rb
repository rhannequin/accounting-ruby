class AddSlugToDebits < ActiveRecord::Migration[5.1]
  def change
    add_column :debits, :slug, :string, unique: true, index: true
  end
end
