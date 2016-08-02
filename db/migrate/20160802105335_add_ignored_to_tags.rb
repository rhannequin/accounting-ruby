class AddIgnoredToTags < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :ignored, :boolean, null: false, default: false
  end
end
