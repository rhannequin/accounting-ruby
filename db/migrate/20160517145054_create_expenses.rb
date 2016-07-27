class CreateExpenses < ActiveRecord::Migration[5.0]
  def change
    create_table :expenses do |t|
      t.date :date
      t.string :reason
      t.decimal :price
      t.string :way

      t.timestamps
    end
  end
end
