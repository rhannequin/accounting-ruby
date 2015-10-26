module Accounting
  class App
    module StatisticsHelper
      def get_statistics(data)
        statistics = {}
        data.each do |month, expenses|
          statistics[month] = tabs.map{|tab| [tab, {}] }.to_h # Init statistics hashes and arrays
          expenses.each do |expense|
            tabs_conditionals(expense).each do |tab|
              if tab[:conditional]
                statistics[month][tab[:name]][:total] ||= 0
                statistics[month][tab[:name]][:total] += expense[:price]
                (statistics[month][tab[:name]][:expenses] ||= []) << expense
              end
            end
          end
        end
        statistics
      end

      def tabs_conditionals(expense)
        [
          { conditional: (expense[:categories].include? 'lunch'), name: :lunch },
          { conditional: (expense[:categories].include? 'fastfood'), name: :fastfood },
          { conditional: (expense[:categories].include? 'shopping'), name: :shopping }
        ]
      end

      def tabs
        tabs = tabs_conditionals categories: [] # Fake expense to get array
        tabs.map{ |tab| tab[:name] }
      end
    end
  end
end
