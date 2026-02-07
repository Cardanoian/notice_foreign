class ProcessDocumentJob < ApplicationJob
  queue_as :default

  def perform(original_doc_id)
    original_doc = OriginalDoc.find(original_doc_id)
    original_doc.update!(status: :processing)

    file = original_doc.file
    unless file.attached?
      original_doc.update!(status: :failed)
      Rails.logger.error("ProcessDocumentJob failed: No file attached for OriginalDoc##{original_doc_id}")
      return
    end

    languages = original_doc.uploader.selected_languages

    translations = GeminiService.process_document(
      file_data: file.download,
      content_type: file.content_type,
      languages: languages
    )

    if translations.empty?
      original_doc.update!(status: :failed)
      return
    end

    ActiveRecord::Base.transaction do
      translations.each do |translation|
        original_doc.docs.create!(
          title: translation["title"],
          content: translation["content"],
          language: translation["lang"]
        )
      end
      original_doc.update!(status: :completed)
    end
  rescue => e
    Rails.logger.error("ProcessDocumentJob failed: #{e.message}")
    original_doc&.update!(status: :failed)
    raise e
  end
end
