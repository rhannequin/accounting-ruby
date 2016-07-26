class Expense < ApplicationRecord
  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings

  scope :with_tags, -> { includes(:tags) }
  scope :date_desc_order, -> { order(date: :desc) }
  scope :all_ordered, -> { with_tags.date_desc_order }
end
