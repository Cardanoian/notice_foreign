class School < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :original_docs, dependent: :destroy
  has_many :docs, through: :original_docs

  validates :name, presence: true, uniqueness: true
end
