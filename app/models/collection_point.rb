class CollectionPoint < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  def as_map_json
    {
      id: id,
      name: name,
      latitude: latitude.to_f,
      longitude: longitude.to_f,
      user: user.name,
      created_at: created_at.strftime("%d/%m/%Y")
    }
  end
end
