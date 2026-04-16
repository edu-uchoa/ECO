class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :posts, dependent: :destroy

  has_many :sent_conversations, class_name: "PrivateConversation", foreign_key: :sender_id, dependent: :destroy
  has_many :received_conversations, class_name: "PrivateConversation", foreign_key: :receiver_id, dependent: :destroy
  has_many :messages, dependent: :destroy

  def conversations
    PrivateConversation.where("sender_id = ? OR receiver_id = ?", id, id)
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true, uniqueness: true
  validates :email_address,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password,
            presence: true,
            length: { minimum: 6 },
            if: -> { new_record? }

  validates :password,
            length: { minimum: 6 },
            allow_blank: true,
            if: -> { !new_record? }

  def profile_complete?
    cpf.present? && telefone.present? && uf.present? && cidade.present?
  end
end

