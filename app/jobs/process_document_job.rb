class ProcessDocumentJob < ApplicationJob
  queue_as :default

  def perform(original_doc_id)
    original_doc = OriginalDoc.find(original_doc_id)
    update_status!(original_doc, :processing)

    file = original_doc.file
    unless file.attached?
      update_status!(original_doc, :failed)
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
      update_status!(original_doc, :failed)
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

    broadcast_status_update(original_doc.reload)
  rescue => e
    Rails.logger.error("ProcessDocumentJob failed: #{e.message}")
    if original_doc
      original_doc.update!(status: :failed)
      broadcast_status_update(original_doc)
    end
    raise e
  end

  private

  def update_status!(original_doc, status)
    original_doc.update!(status: status)
    broadcast_status_update(original_doc)
  end

  def broadcast_status_update(original_doc)
    Turbo::StreamsChannel.broadcast_replace_to(
      "admin_original_docs",
      target: "row_original_doc_#{original_doc.id}",
      partial: "admin/original_docs/original_doc_row",
      locals: { doc: original_doc }
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      original_doc,
      target: "status_original_doc_#{original_doc.id}",
      partial: "admin/original_docs/original_doc_status",
      locals: { doc: original_doc }
    )
  end
end
