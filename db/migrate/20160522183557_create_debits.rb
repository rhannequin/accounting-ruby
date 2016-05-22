class CreateDebits < ActiveRecord::Migration[5.0]
  def change
    create_table :debits do |t|
      t.string :reason
      t.decimal :price
      t.string :way
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
