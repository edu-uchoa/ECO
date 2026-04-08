class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :posts, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
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

