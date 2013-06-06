class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin?
      can :manage, :all
    elsif not user.new_record?
      can :manage, Contact
      cannot :manage, User
    else
      can :read, :all
    end
  end
end
