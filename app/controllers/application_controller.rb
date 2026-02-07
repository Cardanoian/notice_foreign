class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern

  before_action :set_current_lang
  helper_method :current_lang

  private

  SUPPORTED_LANGUAGES = %w[ko en zh vi ja es].freeze

  def set_current_lang
    lang = params[:lang].presence || cookies[:lang].presence || "ko"
    @current_lang = SUPPORTED_LANGUAGES.include?(lang) ? lang : "ko"

    if cookies[:lang] != @current_lang
      cookies[:lang] = { value: @current_lang, expires: 1.year.from_now }
    end
  end

  def current_lang
    @current_lang || "ko"
  end
end
