# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    can :manage, Account, account_users: { user_id: user.id }
    can :manage, Expense, account: { account_users: { user_id: user.id } }
    can :manage, Debit, account: { account_users: { user_id: user.id } }
    can :manage, Tag, account: { account_users: { user_id: user.id } }

    return unless user.has_role?(:admin)

    # can :manage, :all
    can :read, :admin_homepage
    can :manage, User
    cannot :destroy, User, id: user.id
  end
end
