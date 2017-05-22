class AddAccountToTag < ActiveRecord::Migration[5.0]
  def change
    add_reference :tags, :account, type: :uuid, foreign_key: true
  end
end
