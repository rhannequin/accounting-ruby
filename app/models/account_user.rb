# frozen_string_literal: true

class AccountUser < ApplicationRecord
  belongs_to :account
  belongs_to :user
end
