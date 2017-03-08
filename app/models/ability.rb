class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    return unless user.has_role?(:admin)

    can :manage, :all
    can :read, :admin_homepage
    cannot :destroy, User, id: user.id
  end
end
