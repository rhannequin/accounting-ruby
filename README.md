# Accounting

This app is meant to help you with accounting, giving you the possibility to add expenses, debits, with tags and get some interesting data about your behaviour.

## How to use it

Be sure to read the [requirements](#requirements), [install](#install) and [launch](#launch) paragraphs.

### Expenses

Add every expense you make, with a title, a price, a way of paiement and a date. Every expense will be visible on the home page, by month and date.

### Debits

Tired of repeating some same expenses every month? Try making a debit. With a start date and eventually an end date, it will automatically be added to your expenses list. You can even say what day of the month the debit will be done.

### Tags

Add tags to your expenses and debits to see charts showing you how much you spend each month, for each tag.

Some tags can be ignored from the monthly spent money amount. You can edit a tag and mark it as " to be ignored".

## Requirements

* Ruby 2.5.x
* Rails 5.x
* Bundler

## Install

```bash
$ git clone https://github.com/rhannequin/accounting-ruby.git
$ cd accounting-ruby
$ bundle install
$ bundle exec rails db:migrate
$ cp config/application.example.yml config/application.yml
```

## Launch

```
$ bundle exec rails server  # Visit http://localhost:3000
```

## Test

Still work in progress.

```bash
$ bundle exec rspec
```
