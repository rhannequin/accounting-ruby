class Expense < ApplicationRecord
  extend FriendlyId

  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings
  belongs_to :account

  friendly_id :slug_candidates, use: [:slugged, :finders]
  after_create :update_slug # Force to regenerate slug with id

  scope :include_tags, -> { includes(:tags) }
  scope :include_taggings, -> { includes(:taggings) }
  scope :with_taggings, -> { joins(:taggings) }
  scope :date_desc_order, -> { order(date: :desc) }
  scope :all_ordered, -> { include_tags.date_desc_order }
  scope :with_these_tags, -> (ids) { with_taggings.where(taggings: { tag_id: ids }) }
  scope :date_after, -> (date) { where(['date > ?', date]) }

  validates :reason, :date, :price, presence: true

  def slug_candidates
    if id
      splitted_id = id.split('-').first
      parameterized_reason = reason.parameterize
      ["#{splitted_id}-#{parameterized_reason}-#{date}"]
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
end
