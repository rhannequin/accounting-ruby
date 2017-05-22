class CreateTaggings < ActiveRecord::Migration[5.0]
  def change
    create_table :taggings, id: :uuid do |t|
      t.references :tag, type: :uuid, index: true
      t.references :taggable, type: :uuid, polymorphic: true, index: true
      t.timestamps
    end
  end
end
