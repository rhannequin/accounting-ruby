# frozen_string_literal: true

require "nokogiri"
require "date"
require "yaml"

require_relative "expense_parser"


namespace :import do
  task expenses: :environment do
    log_timer = LogTimer.new
    puts
    puts "== Start importing task at #{log_timer.start_time} =="
    puts
    clean_database
    process_loop
    puts
    puts "== End importing task at #{log_timer.end_time} (#{log_timer.show}) =="
    puts
  end
end


def clean_database
  log_timer = LogTimer.new
  puts
  puts "Emptying database..."
  Account.destroy_all
  puts "... done in #{log_timer.show}."
  puts
end


def process_loop
  config = YAML.load_file(Rails.root.join("lib", "tasks", "import", "expenses_config.yml"))
  config.fetch("accounts").each do |data|
    log_timer = LogTimer.new
    account = Account.create(name: data.fetch("name"))
    account_owners = data.fetch("owners").map { |o| User.find_by(name: o) }
    account.users = account_owners
    puts
    puts "== Start importing expenses from #{account.name} for #{account_owners.map(&:name).join(", ")} =="
    result = process_import(data, account)
    puts "== End importing expenses from #{account.name} =="
    puts "== Imported #{result[:imported]} transactions in #{log_timer.show} =="
    puts
  end
end


def process_import(data, account)
  filename = Rails.root.join("tmp", "expenses", data.fetch("file"))
  doc = File.open(filename) { |f| Nokogiri::HTML(f, nil, Encoding::UTF_8.to_s) }
  transactions = doc.css("ul.transactionList li")
  expenses = []
  tags = []
  transactions.each do |entry|
    next if entry.attr("id").nil?
    parsed = ExpenseParser.new(entry).parse
    tag = {
      name: parsed[:tag],
      ignored: false,
      account: account,
      expense_bankin_id: parsed[:bankin_id]
    }
    if data.fetch("ignored").map { |ign| parsed[:reason].include?(ign) }.include?(true)
      tags << { name: "ignore", ignored: true, account: account, expense_bankin_id: parsed[:bankin_id] }
    end
    tags << tag
    expenses << Expense.new(parsed.except(:tag).merge(account: account))
  end
  if data.fetch("initial_amount") != 0
    id = rand(10**7..(10**8-1))
    first_date = expenses.map(&:date).uniq.sort.first
    expenses << Expense.new(account: account, bankin_id: id, date: first_date, reason: "First expense", price: data.fetch("initial_amount"))
    tags << { name: "ignore", ignored: true, account: account, expense_bankin_id: id }
  end
  Expense.import(expenses)
  tags.each do |tag|
    t = Tag.find_or_initialize_by(tag.except(:expense_bankin_id))
    t.expenses << Expense.find_by(bankin_id: tag[:expense_bankin_id])
    t.save
  end
  { status: :success, imported: transactions.size }
end


class String
  def trim
    self.split("\n").map(&:strip).join("")
  end
end

class LogTimer
  attr_accessor :start_time, :end_time

  def initialize
    @start_time = Time.zone.now
  end

  def stop
    @end_time = Time.zone.now
  end

  def show
    self.stop
    "#{(end_time - start_time).round(2)} seconds"
  end
end
