class Expense < ApplicationRecord
  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings

  scope :with_tags, -> { includes(:tags) }
  scope :with_taggings, -> { joins(:taggings) }
  scope :date_desc_order, -> { order(date: :desc) }
  scope :all_ordered, -> { with_tags.date_desc_order }
  scope :with_these_tags, -> (ids) { with_taggings.where(taggings: { tag_id: ids }) }

  validates :reason, :date, :price, presence: true
end
