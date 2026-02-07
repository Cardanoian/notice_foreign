class SchoolsController < ApplicationController
  allow_unauthenticated_access

  def index
    @schools = School.all
  end

  def show
    @school = School.find(params[:id])
    @docs = @school.docs.recent.by_language(@current_lang)
  end
end
