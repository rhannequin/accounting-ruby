class AccountsController < ApplicationController
  before_action :authenticate_user!

  def index
    @accounts = Account.includes(:expenses, :debits).from_user(current_user)
  end
end
