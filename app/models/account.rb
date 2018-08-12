# frozen_string_literal: true

class Account < ApplicationRecord
  extend FriendlyId

  has_many :expenses, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :account_users, dependent: :destroy
  has_many :users, through: :account_users

  friendly_id :slug_candidates, use: [:slugged, :finders]
  after_create :update_slug # Force to regenerate slug with id

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

  def current_amount
    return 0 unless expenses.any?
    total_expenses_amount = expenses.map(&:price).sum
    current_amount = total_expenses_amount
    current_amount
  end
end
