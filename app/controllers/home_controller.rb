class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    @schools = School.all
  end
end
