class ModerationLog < ApplicationRecord
  belongs_to :collection_point
  belongs_to :moderator, class_name: "User"

  enum :action_type, {
    approved: "approved",
    rejected: "rejected"
  }

  validates :action_type, presence: true, inclusion: { in: action_types.keys }
end
