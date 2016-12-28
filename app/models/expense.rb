class Expense < ApplicationRecord
  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings

  scope :include_tags, -> { includes(:tags) }
  scope :include_taggings, -> { includes(:taggings) }
  scope :with_taggings, -> { joins(:taggings) }
  scope :date_desc_order, -> { order(date: :desc) }
  scope :all_ordered, -> { include_tags.date_desc_order }
  scope :with_these_tags, -> (ids) { with_taggings.where(taggings: { tag_id: ids }) }
  scope :date_after, -> (date) { where(['date > ?', date]) }

  validates :reason, :date, :price, presence: true
end
