module Accounting
  class App
    module PrepareHelper

      # Main method

      def prepare_data(data)
        data = sort_by_date data
        data = group_by_month data
        data = add_debits data
      end


      # Sort all expenses by date DESC

      def sort_by_date(data)
        data.sort_by { |exp| exp[:date] }.reverse
      end


      # Split expenses in groups of months

      def group_by_month(data)
        groups = {}
        data.each do |exp|
          (groups[exp[:date].beginning_of_month] ||= []) << exp
        end
        groups
      end


      # Add monthly expenses from config file

      def add_debits(data)
        months_involved = data.keys.map(&:to_date).sort
        settings.debits.each do |debit|
          start_date = debit['start_date']
          end_date = debit['end_date']
          months_involved.each do |month|
            if month >= start_date && (end_date.is_a?(Date) ? month <= end_date : true)
              expense = {
                date: month,
                reason: debit['reason'],
                price: debit['price'],
                way: debit['way'],
                categories: (debit['categories'].nil? ? [] : debit['categories'].split(',').map(&:strip))
              }
              data[month] << expense
            end
          end
        end
        data
      end


      # Calculate current amiunt of money on account

      def calculate_current_money(data, current_money)
        data.each do |month, expenses|
          expenses.each do |expense|
            current_money += expense[:price]
          end
        end
        current_money
      end
    end
  end
end
