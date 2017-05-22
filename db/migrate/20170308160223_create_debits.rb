class CreateDebits < ActiveRecord::Migration[5.0]
  def change
    create_table :debits, id: :uuid do |t|
      t.string :reason
      t.decimal :price
      t.integer :day
      t.string :way
      t.date :start_date
      t.date :end_date
      t.references :account, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
