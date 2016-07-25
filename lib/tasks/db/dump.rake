namespace :db do
  desc 'Dump expenses and debits from database into seed file'
  task dump: :environment do
    dump = Rails.root.join 'tmp', 'seed.rb'
    File.truncate(dump, 0)
    SeedDump.dump(Expense, file: dump)
    SeedDump.dump(Debit, file: dump, append: true)
  end
end
