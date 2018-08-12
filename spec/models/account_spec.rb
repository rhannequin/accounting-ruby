# frozen_string_literal: true

require "rails_helper"

RSpec.describe Account, type: :model do
  describe "#current_amount" do
    let(:account) { Account.create }

    before(:each) do
      today = Date.today
      account.expenses << Expense.create(reason: "Init", date: (today - 2.month).beginning_of_month, price: 40)
      account.expenses << Expense.create(date: today.beginning_of_month, price: -15)
      account.expenses << Expense.create(date: (today - 1.month).beginning_of_month, price: -10)
    end

    it "returns the correct amount" do
      expect(account.current_amount).to eq(40 - 15 - 10)
    end
  end
end
