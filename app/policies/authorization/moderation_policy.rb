module Authorization
  class ModerationPolicy
    def initialize(user)
      @user = user
    end

    def access?
      @user.present? && @user.moderator?
    end
  end
end
