class OriginalDoc < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :school
  belongs_to :uploader, class_name: "User"
  has_many :docs, dependent: :destroy

  has_one_attached :file

  enum :status, { pending: "pending", processing: "processing", completed: "completed", failed: "failed" }

  validates :status, presence: true

  scope :recent, -> { order(uploaded_at: :desc) }
end
