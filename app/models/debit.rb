# frozen_string_literal: true

class Debit < ApplicationRecord
  extend FriendlyId

  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings
  belongs_to :account

  friendly_id :slug_candidates, use: [:slugged, :finders]
  after_create :update_slug # Force to regenerate slug with id

  scope :include_tags, -> { includes(:tags) }
  scope :with_taggings, -> { joins(:taggings) }
  scope :with_these_tags, -> (ids) { with_taggings.where(taggings: { tag_id: ids }) }
  scope :end_date_after, -> (date) { where("end_date > ?", date) }
  scope :start_date_before, -> (date) { where("start_date < ?", date) }
  scope :end_date_nil, -> { where(end_date: nil) }

  validates :reason, :price, :day, :start_date, presence: true

  def slug_candidates
    if id
      splitted_id = id.split("-").first
      parameterized_reason = reason.parameterize
      ["#{splitted_id}-#{parameterized_reason}"]
    else
      [:reason]
    end
  end

  def should_generate_new_friendly_id?
    reason_changed? || super
  end

  def update_slug
    valid?
  end

  def applies_this_month?(month)
    beginning_of_month = month.beginning_of_month
    end_of_month = month.end_of_month
    (
      (beginning_of_month..end_of_month).cover?(start_date) ||
      (beginning_of_month..end_of_month).cover?(end_date)
    ) || (
      start_date < month &&
      (end_date ? end_date > month : true)
    )
  end
end
