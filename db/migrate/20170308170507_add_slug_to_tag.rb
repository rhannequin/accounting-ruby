class AddSlugToTag < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :slug, :string, unique: true, index: true
  end
end
