class Debit < ApplicationRecord
  attr_accessor :date

  acts_as_taggable
end
