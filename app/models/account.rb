class Account < ApplicationRecord
  has_many :debits, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :account_users, dependent: :destroy
  has_many :users, through: :account_users

  def current_amount
    return 0 unless expenses.any?
    first_date = expenses.select(:date).order(:date).first.date
    all_months = (first_date..Date.today).to_a.map(&:beginning_of_month).uniq
    total_expenses_amount = expenses.map(&:price).sum
    current_amount = total_expenses_amount
    current_amount += debits_amount(all_months)
    current_amount
  end

  def debits_amount(months)
    amount = 0
    debits.each do |debit|
      months.each do |month|
        if debit.applies_this_month?(month)
          amount += debit.price
        end
      end
    end
    amount
  end
end
