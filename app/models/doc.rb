class Doc < ApplicationRecord
  belongs_to :original_doc
  has_one :school, through: :original_doc

  validates :title, presence: true
  validates :language, presence: true
  validates :original_doc_id, uniqueness: { scope: :language }

  scope :by_language, ->(lang) { where(language: lang) }
  scope :recent, -> { joins(:original_doc).merge(OriginalDoc.recent) }
end
