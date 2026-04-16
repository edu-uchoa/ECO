class Message < ApplicationRecord
  belongs_to :user
  belongs_to :private_conversation

  validates :content, presence: true

  default_scope { order(created_at: :asc) }
end
