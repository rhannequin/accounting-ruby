# Accounting

This app is meant to help you with accounting, giving you the possibility to add expenses, debits, with tags and get some interesting data about your behaviour.

## How to use it

Be sure to the requirements, install and launch paragraphs.

### Expenses

Add every expense you make, with a title, a price, a way of paiement and a date. Every expense will be visible on the home page, by month and date.

### Debits

Tired of repeating some same expenses every month? Try making a debit. With a start date and eventually an end date, it will automatically be added to your expenses list. You can ever say what day of the month the debit will be done.

### Tags

Add tags to your expenses and debits to see charts showing you how much you spend each month, for each tag.

## Requirements

* Ruby 2.3.x
* Rails 5.x
* Bundler

## Install

```
$ git clone https://github.com/rhannequin/accounting-ruby.git
$ cd accounting-ruby
$ bundle install
$ bundle exec rails db:migrate
```

## Launch

```
$ bundle exec rails s  # Visit http://localhost:3000
```

# Test

Work in progress...
