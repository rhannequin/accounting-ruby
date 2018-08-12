# frozen_string_literal: true

class Tag < ApplicationRecord
  extend FriendlyId

  friendly_id :slug_candidates, use: [:slugged, :finders]
  after_create :update_slug # Force to regenerate slug with id

  belongs_to :account
  has_many :taggings, dependent: :destroy
  has_many :expenses, through: :taggings, source: :taggable, source_type: "Expense"

  scope :ignored, -> { where(ignored: true) }

  def slug_candidates
    if id
      splitted_id = id.split("-").first
      parameterized_name = name.parameterize
      ["#{splitted_id}-#{parameterized_name}"]
    else
      [:name]
    end
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def update_slug
    valid?
  end
end
