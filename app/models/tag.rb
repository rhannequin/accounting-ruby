class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :expenses, through: :taggings, source: :taggable, source_type: 'Expense'
  has_many :debits, through: :taggings, source: :taggable, source_type: 'Debit'

  scope :ignored, -> { where(ignored: true) }
end
