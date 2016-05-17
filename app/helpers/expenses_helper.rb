module ExpensesHelper
  def currency(dec)
    "#{'%.2f' % dec}€"
  end
end
