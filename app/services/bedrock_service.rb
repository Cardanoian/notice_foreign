class BedrockService
  class << self
    def client
      @client ||= Aws::BedrockRuntime::Client.new(
        region: ENV.fetch("AWS_REGION", "us-east-1"),
        credentials: Aws::Credentials.new(
          ENV["AWS_ACCESS_KEY_ID"],
          ENV["AWS_SECRET_ACCESS_KEY"]
        )
      )
    end

    def chat(context:, message:)
      system_prompt = <<~PROMPT
        당신은 학교 안내장 도우미입니다. 아래 문서 내용을 기반으로 사용자의 질문에 친절하게 답변해주세요.
        문서에 없는 내용은 "문서에서 해당 정보를 찾을 수 없습니다"라고 안내해주세요.
        답변은 간결하고 명확하게 해주세요.
        반드시 사용자가 질문한 언어와 동일한 언어로 답변하세요. 예: 중국어로 질문하면 중국어로, 일본어로 질문하면 일본어로, 영어로 질문하면 영어로 답변하세요.

        [문서 내용]
        #{context}
      PROMPT

      body = {
        anthropic_version: "bedrock-2023-05-31",
        max_tokens: 1024,
        system: system_prompt,
        messages: [
          { role: "user", content: message }
        ]
      }

      response = client.invoke_model(
        model_id: "anthropic.claude-v2",
        body: body.to_json,
        content_type: "application/json",
        accept: "application/json"
      )

      result = JSON.parse(response.body.read)
      result.dig("content", 0, "text") || "응답을 생성할 수 없습니다."
    rescue Aws::BedrockRuntime::Errors::ServiceError => e
      Rails.logger.error("Bedrock API Error: #{e.message}")
      "AI 서비스에 일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
    rescue => e
      Rails.logger.error("Unexpected Error: #{e.message}")
      "오류가 발생했습니다. 관리자에게 문의해주세요."
    end

    def process_document(content:, languages:)
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

        지원 언어: #{languages.join(', ')}
      PROMPT

      body = {
        anthropic_version: "bedrock-2023-05-31",
        max_tokens: 8192,
        system: system_prompt,
        messages: [
          { role: "user", content: content }
        ]
      }

      response = client.invoke_model(
        model_id: "anthropic.claude-v2",
        body: body.to_json,
        content_type: "application/json",
        accept: "application/json"
      )

      result = JSON.parse(response.body.read)
      response_text = result.dig("content", 0, "text") || "[]"

      json_match = response_text.match(/\[[\s\S]*\]/)
      json_match ? JSON.parse(json_match[0]) : []
    rescue => e
      Rails.logger.error("Document Processing Error: #{e.message}")
      []
    end
  end
end
