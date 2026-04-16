class PrivateConversation < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  has_many :messages, dependent: :destroy

  validates :sender_id, uniqueness: { scope: :receiver_id }

  def self.between(user1, user2)
    where(sender: user1, receiver: user2)
      .or(where(sender: user2, receiver: user1))
      .first
  end

  def other_user(user)
    user == sender ? receiver : sender
  end
end
