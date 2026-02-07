module Admin
  class OriginalDocsController < ApplicationController
    before_action :require_school_admin

    def index
      @original_docs = current_user_docs.includes(:school, :uploader).recent
    end

    def show
      @original_doc = current_user_docs.includes(docs: []).find(params[:id])
      @docs = @original_doc.docs.order(:language)
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_original_docs_path, alert: "해당 문서에 대한 권한이 없습니다."
    end

    def new
      @original_doc = OriginalDoc.new
    end

    def create
      @original_doc = OriginalDoc.new(original_doc_params)
      @original_doc.uploader = Current.user
      @original_doc.uploaded_at = Time.current
      @original_doc.school = Current.user.school

      if @original_doc.save
        ProcessDocumentJob.perform_later(@original_doc.id)
        redirect_to admin_original_docs_path, notice: "문서가 업로드되었습니다. AI 처리가 시작됩니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @original_doc = current_user_docs.find(params[:id])
      @original_doc.destroy
      redirect_to admin_original_docs_path, notice: "문서가 삭제되었습니다."
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_original_docs_path, alert: "해당 문서에 대한 권한이 없습니다."
    end

    private

    def require_school_admin
      unless Current.user&.school_admin? || Current.user&.admin?
        redirect_to root_path, alert: "관리자 권한이 필요합니다."
      end
    end

    def current_user_docs
      Current.user.school.original_docs
    end

    def original_doc_params
      params.require(:original_doc).permit(:file, :original_file)
    end
  end
end
