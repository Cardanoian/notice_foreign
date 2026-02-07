AI를 활용한 다문화 안내장 번역 및 안내

개발 효율성과 실용성을 극대화한 'Kiro-Remark 에듀 허브(가칭)'를 다음과 같이 정의합니다.

### **1\. 앱 정의**

**\[ 앱 명칭 \]**는 교육자가 업로드한 정책 및 교육 자료를 AI가 마크다운(Markdown) 형식으로 자동 변환·정리하고, 사용자는 이를 미려한 인터페이스로 확인하며 관련 내용에 대해 AI와 실시간 대화할 수 있는 '초경량 지능형 문서 열람 시스템'입니다.

### **2\. 주요 역할 및 기능**

- **관리자 (교육자/행정가)**
  - **자료 업데이트**: PDF, 텍스트, 이미지 등 다양한 형식의 가정통신문이나 교육 정책 자료를 업로드합니다.
  - **제목 추출**: 제목은 전체 내용을 간단히 한 문장으로 요약합니다.
  - **콘텐츠 관리**: **콘텐츠 관리 및 다국어 처리**: AWS Bedrock의 claude ai를 활용하여 업로드된 자료를 분석하고, 다음의 JSON 구조로 변환된 결과를 수신합니다. 수신된 데이터는 챗봇이 참고할 지식 베이스(Context)를 갱신하는 데 사용됩니다.  
    **AI 출력 형식 (API Response Spec):**  
    **\[**  
     **{"lang": "ko", "title": "한국어 제목", "content": "한국어 마크다운 텍스트..."},**  
     **{"lang": "en", "title": "English Title", "content": "English markdown text..."},**  
     **// 사용자가 선택한 언어 (예: 스페인어 'es') {"lang": "es", "title": "El título de español", "content": "español markdown text..."}, ...**  
    **\]**
- **사용자 (이주배경 학부모 및 주민)**
  - **학교 선택**: text 입력창에 글자를 쓰면 DB에서 미리 읽어온 학교 목록에서 해당 텍스트가 들어있는 학교 명단이 아래에 뜨고, 클릭하면 선택하여 입장하게 됩니다.
  - **문서 선택**: 선택된 학교의 id를 읽어서 해당 학교 id로 만들어진 문서 명단을 최신순으로 표시하며 검색 기능을 제공합니다.
  - **스마트 뷰어**: **React 컴포넌트(RemarkViewer)**가 마크다운 문서를 remark 라이브러리를 통해 웹/모바일에서 가독성 높고 아름다운 디자인으로 확인합니다. (React 통합 방식을 명확히 합니다.)
  - **챗봇 서비스**: NotebookLM 스타일의 챗봇을 통해 문서 내용에 기반한 정확하고 근거 있는 답변을 모색합니다. 예를 들어 "이번 주 소풍 준비물이 뭐야?"라고 물으면 챗봇이 문서의 해당 부분을 찾아 이를 바탕으로 답변합니다. 해당 문서의 내용을 markdown 형식으로 시스템 프롬프트에 추가하여 문서 내용에 맞는 답을 하도록 합니다. 사용자 편의성 확보를 위해 최근 접속 학교 목록과 채팅 내역 모두 Browser의 **localStorage**에 저장하여 재접속 시에도 정보가 유지되도록 합니다. (최근 접속 학교 기능을 명확히 반영합니다.)

### **3\. 핵심 아키텍처 및 구현 방안**

- **문서 처리 루틴**: AWS Kiro의 **Agent Hooks**를 사용하여 관리자가 파일을 업로드하거나 수정할 때마다 자동으로 마크다운 변환 및 remark 렌더링 준비를 마칩니다.
- **지능형 대화**: AWS bedrock의 claude 모델을 활용합니다. 사용자의 질문과 가장 관련 있는 내용을 해당 문서에서 찾아 답변을 제시합니다. 채팅 내역은 Browser의 localstorage에 저장되어 다시 접속해도 볼 수 있도록 합니다.
- **다국어 지원**: AI가 마크다운 변환 단계에서 원문의 전체 내용을 요약 없이 사용자의 모국어로 번역하여 제공함으로써 소통의 장벽을 낮춥니다.

### **4\. 앱의 차별점**

이 앱은 복잡한 기능을 배제하고 '문서의 시각화(Remark)'와 '문서 기반 대화'라는 두 가지 핵심 가치에만 집중합니다. 이를 통해 교육 현장에서는 최소한의 리소스로 고도화된 다문화 교육 지원 시스템을 구축할 수 있으며, 사용자는 마치 개인 비서와 대화하듯 학교 정보를 파악할 수 있습니다.

### **5\. 기술 스택**

백엔드: Ruby on rails 8, react-rails 젬  
DB: SQLite  
프론트엔드: rails ERB(일부 react Component 통합)  
AI모델: AWS Bedrock claude-v2

### **6\. DB구성**

1. user_info

- Colums: user_id, school_id, selected_lang(text), created_at(datetime), updated_at(datetime)
- user_id, school_id를 인덱스로 사용

2. school_info

- Columns: school_id, school_name(string, unique), location(string), created_at(datetime), updated_at(datetime)
- school_id, school_name, location을 인덱스로 사용

3. docs

- 관리자가 안내장을 업로드하면 DB에는 doc_id라는 unique한 primary 값이 생성되고, 문서의 제목과 내용, 언어를 저장합니다.
- Columns: doc_id, original_id(**FK to original_doc.id, Index**), title(string), content(text), language(string)
- original_id, language로 인덱스를 사용

4. original_doc

- Columns: **id (PK)**, school_id (FK, Index), uploader_id (FK, Index), uploaded_at (Index), original_file (text), status (string)
