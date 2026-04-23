class Message < ApplicationRecord
  belongs_to :user
  belongs_to :private_conversation
  belongs_to :post, optional: true

  validates :content, presence: true

  default_scope { order(created_at: :asc) }

  def claim_message?
    post_id.present?
  end
end
