class Debit < ApplicationRecord
  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings

  scope :with_tags, -> { includes(:tags) }

  validates :reason, :price, :day, :start_date, presence: true
end
