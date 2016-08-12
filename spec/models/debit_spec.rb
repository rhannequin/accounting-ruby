require 'rails_helper'

RSpec.describe Debit, type: :model do
  it 'does #applies_this_month' do
    today = Date.today
    debit = Debit.new start_date: (today - 1.month), end_date: (today + 1.month)
    expect(debit.applies_this_month?(today)).to be_truthy
  end

  it 'does not #applies_this_month' do
    today = Date.today
    debit = Debit.new start_date: (today - 2.month), end_date: (today - 1.month)
    expect(debit.applies_this_month?(today)).to be_falsey
  end
end
