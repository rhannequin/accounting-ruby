class Debit < ApplicationRecord
  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings
end
