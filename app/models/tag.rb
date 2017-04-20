class Tag < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  belongs_to :user
  has_many :taggings, dependent: :destroy
  has_many :expenses, through: :taggings, source: :taggable, source_type: 'Expense'
  has_many :debits, through: :taggings, source: :taggable, source_type: 'Debit'

  scope :ignored, -> { where(ignored: true) }

  def should_generate_new_friendly_id?
    saved_change_to_name? || super
  end
end
