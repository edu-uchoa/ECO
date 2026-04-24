class Review < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true, length: { maximum: 500 }
  validates :user_id, uniqueness: { scope: :post_id, message: "já avaliou este item" }

  validate :only_taken_posts
  validate :not_post_owner

  private

  def only_taken_posts
    errors.add(:base, "Só é possível avaliar itens já doados") if post&.status != "taken"
  end

  def not_post_owner
    errors.add(:base, "Você não pode avaliar seu próprio item") if post&.user_id == user_id
  end
end
