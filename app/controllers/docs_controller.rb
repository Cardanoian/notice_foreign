class DocsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_school
  before_action :set_doc, only: [ :show ]

  def index
    @docs = @school.docs.recent.by_language(@current_lang)
  end

  def show
    redirect_to_translated_doc
  end

  private

  def set_school
    @school = School.find(params[:school_id])
  end

  def set_doc
    @doc = @school.docs.find(params[:id])
  end

  def redirect_to_translated_doc
    return if @doc.language == @current_lang

    translated = @doc.original_doc.docs.find_by(language: @current_lang)
    redirect_to school_doc_path(@school, translated), status: :see_other if translated
  end
end
