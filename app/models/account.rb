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
    debits.each do |debit|
      all_months.each do |month|
        beginning_of_month = month.beginning_of_month
        if debit.applies_this_month?(month)
          current_amount += debit.price
        end
      end
    end
    current_amount
  end
end
