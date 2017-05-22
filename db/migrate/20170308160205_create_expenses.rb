class CreateExpenses < ActiveRecord::Migration[5.0]
  def change
    create_table :expenses, id: :uuid do |t|
      t.date :date
      t.string :reason
      t.decimal :price
      t.string :way
      t.references :account, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
