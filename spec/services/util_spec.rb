# frozen_string_literal: true

require "rails_helper"

describe Util do
  context "#order_by_month" do
    let(:expense1) { double("Expense", date: Date.today, price: "1.5") }
    let(:expense2) { double("Expense", date: (Date.today + 1.month), price: "2") }
    let(:expense1_bom) { expense1.date.beginning_of_month }
    let(:expense2_bom) { expense2.date.beginning_of_month }
    let(:list) { [expense1, expense2] }

    subject { described_class.order_by_month(list) }

    it "returns a hash" do
      expect(subject).to be_a(Hash)
    end

    it "has keys by beginning of month dates" do
      expect(subject).to include(expense1_bom)
      expect(subject).to include(expense2_bom)
    end

    it "contains arrays of prices" do
      expect(subject).to include(expense1_bom => [expense1.price.to_f])
      expect(subject).to include(expense2_bom => [expense2.price.to_f])
    end
  end

  context "#fill_empty_months" do
    let(:date1) { Date.today }
    let(:date2) { date1 - 1.month }
    let(:date3) { date1 - 2.month }
    let(:list) { { date3 => 1.5, date1 => 2.5 } }
    let(:dates) { [date3, date2, date1] }

    subject { described_class.fill_empty_months(list, dates) }

    it "returns a hash" do
      expect(subject).to be_a(Hash)
    end

    it "has dates as keys" do
      expect(subject).to include(date1)
      expect(subject).to include(date2)
      expect(subject).to include(date3)
    end

    it "contains prices or [0]" do
      expect(subject).to include(date1 => 2.5)
      expect(subject).to include(date2 => [0])
      expect(subject).to include(date3 => 1.5)
    end
  end
end
