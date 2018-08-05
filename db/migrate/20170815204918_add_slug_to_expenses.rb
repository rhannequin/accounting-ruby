class AddSlugToExpenses < ActiveRecord::Migration[5.1]
  def change
    add_column :expenses, :slug, :string, unique: true, index: true
  end
end
