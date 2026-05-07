class CollectionPoint < ApplicationRecord
  belongs_to :user
  belongs_to :approver, class_name: "User", foreign_key: :approved_by, optional: true
  has_many :moderation_logs, dependent: :destroy

  has_many_attached :images

  enum :status, {
    pending: "pending",
    approved: "approved",
    rejected: "rejected"
  }, default: :pending

  serialize :categories, coder: JSON

  before_validation :normalize_categories

  validates :title, presence: true, length: { minimum: 3, maximum: 120 }
  validates :address, presence: true, length: { minimum: 5, maximum: 255 }
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :opening_hours, length: { maximum: 120 }, allow_blank: true
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :contact_name, length: { maximum: 100 }, allow_blank: true
  validates :contact_phone, length: { maximum: 40 }, allow_blank: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate :must_have_at_least_one_category

  scope :publicly_visible, -> { approved }
  scope :pending_review, -> { pending.order(created_at: :desc) }

  after_commit :sync_chatbot_knowledge, on: [:create, :update, :destroy]

  def approve!(moderator)
    previous = status

    transaction do
      update!(status: :approved, approved_by: moderator.id, approved_at: Time.current, rejection_reason: nil)
      moderation_logs.create!(
        moderator: moderator,
        action_type: :approved,
        previous_status: previous,
        new_status: status,
        reason: nil
      )
    end
  end

  def reject!(moderator, reason)
    previous = status

    transaction do
      update!(status: :rejected, approved_by: moderator.id, approved_at: Time.current, rejection_reason: reason)
      moderation_logs.create!(
        moderator: moderator,
        action_type: :rejected,
        previous_status: previous,
        new_status: status,
        reason: reason
      )
    end
  end

  def as_map_json
    {
      id: id,
      title: title,
      description: description,
      address: address,
      latitude: latitude.to_f,
      longitude: longitude.to_f,
      opening_hours: opening_hours,
      categories: categories,
      contact_name: contact_name,
      contact_phone: contact_phone,
      contact_email: contact_email,
      status: status,
  approved_at: approved_at,
  rejection_reason: rejection_reason,
      user: user.name,
      image_urls: images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true) },
      created_at: created_at.strftime("%d/%m/%Y")
    }
  end

  private

  def sync_chatbot_knowledge
    Chatbot::SyncSourceJob.perform_later("collection_point", id)
  end

  def normalize_categories
    self.categories = Array(categories).map(&:to_s).map(&:strip).reject(&:blank?).uniq
  end

  def must_have_at_least_one_category
    errors.add(:categories, "deve conter ao menos uma categoria") if categories.blank?
  end
end
