class Debit < ApplicationRecord
  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings

  scope :with_tags, -> { includes(:tags) }
  scope :with_taggings, -> { joins(:taggings) }
  scope :with_these_tags, -> (ids) { with_taggings.where(taggings: { tag_id: ids }) }

  validates :reason, :price, :day, :start_date, presence: true
end
