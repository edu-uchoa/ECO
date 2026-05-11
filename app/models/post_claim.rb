class PostClaim < ApplicationRecord
  belongs_to :post
  belongs_to :user

  enum :status, { pending: "pending", accepted: "accepted", rejected: "rejected" }, default: :pending

  validates :post_id, uniqueness: { scope: :user_id, message: "Você já demonstrou interesse neste item." }

  scope :pending_first, -> { order(created_at: :asc) }
end
