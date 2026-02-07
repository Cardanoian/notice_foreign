module Api
  class DocsController < ApplicationController
    allow_unauthenticated_access
    skip_before_action :verify_authenticity_token

    def show
      @doc = Doc.find(params[:id])
      render json: @doc.as_json(only: [ :id, :title, :content, :language ])
    end

    def chat
      @doc = Doc.find(params[:id])
      message = params[:message]

      response = GeminiService.chat(
        context: @doc.content,
        message: message
      )

      render json: { response: response }
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
