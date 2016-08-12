class Debit < ApplicationRecord
  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings

  scope :include_tags, -> { includes(:tags) }
  scope :with_taggings, -> { joins(:taggings) }
  scope :with_these_tags, -> (ids) { with_taggings.where(taggings: { tag_id: ids }) }

  validates :reason, :price, :day, :start_date, presence: true

  def applies_this_month?(month)
    beginning_of_month = month.beginning_of_month
    end_of_month = month.end_of_month
    cond = (
        (beginning_of_month..end_of_month).cover?(start_date) ||
        (beginning_of_month..end_of_month).cover?(end_date)
      ) || (
        start_date < month &&
        (end_date ? end_date > month : true
      )
    )
  end
end
