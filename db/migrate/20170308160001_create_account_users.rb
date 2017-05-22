class CreateAccountUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :account_users do |t|
      t.references :account, type: :uuid, foreign_key: true
      t.references :user, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
