module Api
  class SchoolsController < ApplicationController
    allow_unauthenticated_access
    skip_before_action :verify_authenticity_token

    def index
      schools = School.all
      schools = schools.where(location: params[:location]) if params[:location].present?
      render json: schools.select(:id, :name, :location)
    end

    def locations
      locations = School.where.not(location: [ nil, "" ]).distinct.pluck(:location).sort
      render json: locations
    end
  end
end
