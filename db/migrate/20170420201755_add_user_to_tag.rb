class AddUserToTag < ActiveRecord::Migration[5.0]
  def change
    add_reference :tags, :user, type: :uuid, foreign_key: true
  end
end
