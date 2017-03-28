require 'rails_helper'

RSpec.describe Account, type: :model do
  describe '#current_amount' do
    let(:account) { Account.create }

    before(:each) do
      today = Date.today
      account.expenses << Expense.create(reason: 'Init', date: (today - 2.month), price: 40)
      account.expenses << Expense.create(date: today, price: -15)
      account.debits << Debit.create(start_date: (today - 45.day), price: -10)
    end

    it 'returns the correct amount' do
      expect(account.current_amount).to eq(40 - 15 - 2*10)
    end
  end

  describe '#debits_amount' do
    let(:today) { Date.today }
    let(:account) { Account.create }
    let(:months) { [today - 1.month, today].map(&:beginning_of_month) }

    before(:each) do
      today = Date.today
      account.debits << Debit.create(start_date: today - 1.month, price: -10)
    end

    it 'returns debits amount' do
      expect(account.debits_amount(months)).to eq(-20)
    end
  end
end
