class Account < ApplicationRecord
  belongs_to :user
  has_many :debits
  has_many :expenses
  has_many :tags
end
