class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :name
      t.references :user, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
