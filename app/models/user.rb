class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  belongs_to :school, optional: true
  has_many :uploaded_docs, class_name: "OriginalDoc", foreign_key: :uploader_id, dependent: :nullify

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :selected_lang, presence: true

  AVAILABLE_LANGUAGES = {
    "ko" => "한국어",
    "en" => "English",
    "zh" => "中文",
    "vi" => "Tiếng Việt",
    "ja" => "日本語",
    "es" => "Español"
  }.freeze

  def admin?
    admin
  end

  def school_admin?
    school.present?
  end

  # selected_lang is stored as comma-separated string (e.g. "ko,en,zh")
  def selected_languages
    (selected_lang || "ko").split(",").map(&:strip)
  end

  def selected_languages=(langs)
    self.selected_lang = Array(langs).reject(&:blank?).join(",")
  end
end
