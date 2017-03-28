class Account < ApplicationRecord
  has_many :debits
  has_many :expenses
  has_many :tags
  has_many :account_users, dependent: :destroy
  has_many :users, through: :account_users

  def current_amount
    return 0 unless expenses.any?
    first_date = expenses.select(:date).order(:date).first.date
    all_months = (first_date..Date.today).to_a.map { |d| d.beginning_of_month }.uniq
    total_expenses_amount = self.expenses.map(&:price).sum
    current_amount = total_expenses_amount
    current_amount += debits_amount(all_months)
  end

  def debits_amount(months)
    amount = 0
    debits.each do |debit|
      months.each do |month|
        beginning_of_month = month.beginning_of_month
        if debit.applies_this_month?(month)
          amount += debit.price
        end
      end
    end
    amount
  end
end
