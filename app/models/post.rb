class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many :claim_messages, class_name: "Message", dependent: :nullify
  has_one :review, dependent: :destroy

  STATUSES = %w[available taken].freeze

  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :category, presence: true
  validates :location, presence: true, length: { minimum: 5, maximum: 100 }
  validates :condition, presence: true
  validates :images, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :available, -> { where(status: "available") }

  CATEGORIES = [
    "Eletrônicos",
    "Móveis",
    "Roupas",
    "Livros",
    "Esportes",
    "Cozinha",
    "Decoração",
    "Brinquedos",
    "Ferramentas",
    "Outro"
  ].freeze

  CONDITIONS = [
    "Novo",
    "Pouco Usado",
    "Muito Usado"
  ].freeze

  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_location, ->(location) { where(location: location) if location.present? }

  validate :validate_images

  after_commit :sync_chatbot_knowledge, on: [:create, :update, :destroy]

  private

  def sync_chatbot_knowledge
    Chatbot::SyncSourceJob.perform_later("post", id)
  end

  def validate_images
    return unless images.attached?

    images.each do |image|
      # Validar tipo de conteúdo
      unless %w(image/jpeg image/png image/webp).include?(image.blob.content_type)
        errors.add(:images, "deve ser um arquivo JPEG, PNG ou WEBP")
      end

      # Validar tamanho
      if image.blob.byte_size > 5.megabytes
        errors.add(:images, "não pode exceder 5MB")
      end
    end
  end
end
