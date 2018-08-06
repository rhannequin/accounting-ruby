class AddBankinIdToExpenses < ActiveRecord::Migration[5.2]
  def change
    add_column :expenses, :bankin_id, :integer, limit: 5, unique: true, index: true
  end
end
