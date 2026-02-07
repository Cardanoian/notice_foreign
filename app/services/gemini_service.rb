require "net/http"
require "uri"
require "json"

class GeminiService
  GEMINI_API_BASE = "https://generativelanguage.googleapis.com/v1beta/models"
  MODEL = "gemini-2.5-flash"

  class << self
    def chat(context:, message:)
      system_prompt = <<~PROMPT
        당신은 학교 안내장 도우미입니다. 아래 문서 내용을 기반으로 사용자의 질문에 친절하게 답변해주세요.
        문서에 없는 내용은 "문서에서 해당 정보를 찾을 수 없습니다"라고 안내해주세요.
        답변은 간결하고 명확하게 해주세요.
        반드시 사용자가 질문한 언어와 동일한 언어로 답변하세요. 예: 중국어로 질문하면 중국어로, 일본어로 질문하면 일본어로, 영어로 질문하면 영어로 답변하세요.

        [문서 내용]
        #{context}
      PROMPT

      response = generate_content(
        system_instruction: system_prompt,
        user_message: message,
        max_tokens: 8192
      )

      extract_text(response)
    rescue => e
      Rails.logger.error("Gemini API Error: #{e.message}")
      "AI 서비스에 일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
    end

    def process_document(file_data:, content_type:, languages:)
      system_prompt = <<~PROMPT
        당신은 문서 번역 및 정리 전문가입니다.
        주어진 문서를 분석하여 다음 형식의 JSON 배열로 출력해주세요:
        [
          {"lang": "ko", "title": "한국어 제목", "content": "마크다운 형식의 한국어 내용"},
          {"lang": "en", "title": "English Title", "content": "Markdown formatted English content"},
          ...
        ]

        요구사항:
        1. 각 언어별로 문서를 완전히 번역하세요 (요약하지 말고 전체 내용을 번역)
        2. 마크다운 형식을 사용하여 가독성 있게 정리하세요
        3. 제목은 문서 내용을 간단히 요약한 한 문장으로 작성하세요
        4. 반드시 유효한 JSON 형식으로 출력하세요
        5. JSON 배열만 출력하세요. 다른 텍스트는 포함하지 마세요.

        지원 언어: #{languages.join(", ")}
      PROMPT

      response = generate_content_with_file(
        system_instruction: system_prompt,
        user_message: "첨부된 문서를 분석하고 번역해주세요.",
        file_data: file_data,
        content_type: content_type
      )

      response_text = extract_text(response)
      json_match = response_text.match(/\[[\s\S]*\]/)
      json_match ? JSON.parse(json_match[0]) : []
    rescue => e
      Rails.logger.error("Document Processing Error: #{e.message}")
      []
    end

    private

    def api_key
      ENV.fetch("GEMINI_API_KEY") {
        raise "GEMINI_API_KEY environment variable is not set"
      }
    end

    def generate_content(system_instruction:, user_message:, max_tokens: 1024)
      body = build_request_body(
        system_instruction: system_instruction,
        parts: [ { text: user_message } ],
        max_tokens: max_tokens
      )

      send_request(body)
    end

    def generate_content_with_file(system_instruction:, user_message:, file_data:, content_type:, max_tokens: nil)
      encoded = Base64.strict_encode64(file_data)

      parts = [
        { inline_data: { mime_type: content_type, data: encoded } },
        { text: user_message }
      ]

      body = build_request_body(
        system_instruction: system_instruction,
        parts: parts,
        max_tokens: max_tokens
      )

      send_request(body)
    end

    def build_request_body(system_instruction:, parts:, max_tokens: nil)
      body = {
        system_instruction: {
          parts: [ { text: system_instruction } ]
        },
        contents: [
          {
            role: "user",
            parts: parts
          }
        ]
      }

      body[:generationConfig] = { maxOutputTokens: max_tokens } if max_tokens

      body
    end

    def send_request(body)
      uri = URI("#{GEMINI_API_BASE}/#{MODEL}:generateContent")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 120
      http.open_timeout = 30

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["x-goog-api-key"] = api_key
      request.body = body.to_json

      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        error_body = JSON.parse(response.body) rescue response.body
        raise "Gemini API returned #{response.code}: #{error_body}"
      end

      response
    end

    def extract_text(response)
      data = JSON.parse(response.body)
      data.dig("candidates", 0, "content", "parts", 0, "text") || "응답을 생성할 수 없습니다."
    end
  end
end
