# =============================================================================
# 학교 데이터
# =============================================================================
schools = [
  { name: "중앙초등학교", location: "제주" },
  { name: "현풍초등학교", location: "대구" },
  { name: "포항원동초등학교", location: "경북" }
]

created_schools = schools.map do |school_data|
  School.find_or_create_by!(name: school_data[:name]) do |school|
    school.location = school_data[:location]
  end
end

jeju_school, daegu_school, gyeongbuk_school = created_schools

# =============================================================================
# 관리자 사용자 (각 학교별 1명)
# =============================================================================
admin_jeju = User.find_or_create_by!(email_address: "admin@jungangcho.kr") do |user|
  user.password = "password123"
  user.school = jeju_school
  user.selected_lang = "ko,en"
  user.admin = true
end

admin_daegu = User.find_or_create_by!(email_address: "admin@hyeonpungcho.kr") do |user|
  user.password = "password123"
  user.school = daegu_school
  user.selected_lang = "ko,en"
  user.admin = true
end

admin_gyeongbuk = User.find_or_create_by!(email_address: "admin@pohangwondongcho.kr") do |user|
  user.password = "password123"
  user.school = gyeongbuk_school
  user.selected_lang = "ko,en"
  user.admin = true
end

# =============================================================================
# 안내장 데이터 정의
# =============================================================================
notices = {
  jeju_school => {
    admin: admin_jeju,
    docs: [
      {
        original_file: "봄 소풍 안내문 원본",
        uploaded_at: Time.current - 10.days,
        ko: {
          title: "2026학년도 봄 소풍 안내",
          content: <<~MARKDOWN
            # 2026학년도 봄 소풍 안내

            안녕하세요, 학부모님께.

            다가오는 봄을 맞이하여 중앙초등학교에서는 학생들의 자연 체험과 친목 도모를 위한 봄 소풍을 계획하고 있습니다.

            ## 소풍 일정

            - **날짜**: 2026년 4월 15일 (수요일)
            - **시간**: 오전 9시 ~ 오후 3시
            - **장소**: 한라수목원

            ## 준비물

            1. 도시락 및 음료수
            2. 돗자리
            3. 간식 (개인당 3,000원 이내)
            4. 썬크림 및 모자
            5. 우산 (비 예보 시)

            ## 유의사항

            - 당일 아침 체온 측정 후 발열 시 참가 불가
            - 버스 안에서는 안전벨트 착용 필수
            - 친구들과 함께 행동하고 단체 활동에 적극 참여

            궁금한 점은 담임 선생님께 문의해 주세요.

            감사합니다.
          MARKDOWN
        },
        en: {
          title: "2026 Spring Field Trip Notice",
          content: <<~MARKDOWN
            # 2026 Spring Field Trip Notice

            Dear Parents,

            Jungang Elementary School is planning a spring field trip for students to experience nature and build friendships.

            ## Schedule

            - **Date**: April 15, 2026 (Wednesday)
            - **Time**: 9:00 AM ~ 3:00 PM
            - **Location**: Halla Arboretum

            ## What to Bring

            1. Packed lunch and drinks
            2. Picnic blanket
            3. Snacks (within 3,000 KRW per person)
            4. Sunscreen and hat
            5. Umbrella (in case of rain)

            ## Important Notes

            - Temperature check on the morning of the trip
            - Seat belts must be worn on the bus
            - Stay with friends and participate in group activities

            Please contact the homeroom teacher if you have any questions.

            Thank you.
          MARKDOWN
        }
      },
      {
        original_file: "수학여행 안내문 원본",
        uploaded_at: Time.current - 5.days,
        ko: {
          title: "제주 올레길 체험학습 안내",
          content: <<~MARKDOWN
            # 제주 올레길 체험학습 안내

            안녕하세요, 학부모님께.

            중앙초등학교에서 제주 올레길 체험학습을 진행합니다.

            ## 일정

            - **날짜**: 2026년 5월 20일 (수요일)
            - **시간**: 오전 8시 30분 ~ 오후 2시
            - **코스**: 올레 7코스 (중문~대포)

            ## 참가비

            - 1인당 5,000원 (보험료 포함)
            - 납부 기한: 5월 15일까지

            ## 준비물

            1. 편한 운동화
            2. 물통 (500ml 이상)
            3. 간식
            4. 여벌 옷

            ## 유의사항

            - 출발 10분 전까지 학교 운동장 집합
            - 우천 시 다음 주로 연기

            감사합니다.
          MARKDOWN
        },
        en: {
          title: "Jeju Olle Trail Field Trip Notice",
          content: <<~MARKDOWN
            # Jeju Olle Trail Field Trip Notice

            Dear Parents,

            Jungang Elementary School will be conducting a field trip along the Jeju Olle Trail.

            ## Schedule

            - **Date**: May 20, 2026 (Wednesday)
            - **Time**: 8:30 AM ~ 2:00 PM
            - **Course**: Olle Trail Route 7 (Jungmun ~ Daepo)

            ## Fee

            - 5,000 KRW per student (insurance included)
            - Payment deadline: May 15

            ## What to Bring

            1. Comfortable sneakers
            2. Water bottle (500ml or more)
            3. Snacks
            4. Change of clothes

            ## Important Notes

            - Gather at the school playground 10 minutes before departure
            - Postponed to the following week in case of rain

            Thank you.
          MARKDOWN
        }
      },
      {
        original_file: "학부모 상담 안내문 원본",
        uploaded_at: Time.current - 2.days,
        ko: {
          title: "1학기 학부모 상담 주간 안내",
          content: <<~MARKDOWN
            # 1학기 학부모 상담 주간 안내

            안녕하세요, 학부모님께.

            중앙초등학교에서 1학기 학부모 상담 주간을 운영합니다.

            ## 상담 기간

            - **날짜**: 2026년 4월 21일(월) ~ 4월 25일(금)
            - **시간**: 오후 2시 ~ 오후 5시

            ## 상담 방법

            - 대면 상담 (교실) 또는 전화 상담 선택 가능
            - 1인당 상담 시간: 15분

            ## 신청 방법

            1. 가정통신문 하단의 신청서를 작성하여 제출
            2. 희망 날짜와 시간을 3순위까지 기재
            3. 신청 기한: 4월 16일(수)까지

            많은 참여 부탁드립니다.

            감사합니다.
          MARKDOWN
        },
        en: {
          title: "First Semester Parent-Teacher Conference",
          content: <<~MARKDOWN
            # First Semester Parent-Teacher Conference

            Dear Parents,

            Jungang Elementary School will hold a parent-teacher conference week.

            ## Conference Period

            - **Date**: April 21 (Mon) ~ April 25 (Fri), 2026
            - **Time**: 2:00 PM ~ 5:00 PM

            ## Conference Method

            - In-person (classroom) or phone conference available
            - 15 minutes per parent

            ## How to Apply

            1. Fill out the application form at the bottom of this notice
            2. Write your preferred dates and times (up to 3 choices)
            3. Deadline: April 16 (Wed)

            We look forward to your participation.

            Thank you.
          MARKDOWN
        }
      }
    ]
  },
  daegu_school => {
    admin: admin_daegu,
    docs: [
      {
        original_file: "여름 방학 안내문 원본",
        uploaded_at: Time.current - 8.days,
        ko: {
          title: "2026학년도 여름 방학 안내",
          content: <<~MARKDOWN
            # 2026학년도 여름 방학 안내

            안녕하세요, 학부모님께.

            현풍초등학교 여름 방학 일정을 안내드립니다.

            ## 방학 기간

            - **방학**: 2026년 7월 18일(금) ~ 8월 24일(일)
            - **개학일**: 2026년 8월 25일(월)

            ## 방학 중 프로그램

            1. **수학 보충학습** (7/21 ~ 7/25, 오전 9시~11시)
            2. **영어 캠프** (7/28 ~ 8/1, 오전 9시~12시)
            3. **독서 교실** (8/4 ~ 8/8, 오전 10시~12시)

            ## 생활 지도

            - 규칙적인 생활 습관 유지
            - 물놀이 안전 수칙 준수
            - 하루 30분 이상 독서

            ## 과제

            - 독서록 5권 작성
            - 일기 10편 이상

            즐거운 방학 보내세요!

            감사합니다.
          MARKDOWN
        },
        en: {
          title: "2026 Summer Vacation Notice",
          content: <<~MARKDOWN
            # 2026 Summer Vacation Notice

            Dear Parents,

            We would like to inform you about the summer vacation schedule at Hyeonpung Elementary School.

            ## Vacation Period

            - **Vacation**: July 18 (Fri) ~ August 24 (Sun), 2026
            - **School Reopening**: August 25 (Mon), 2026

            ## Programs During Vacation

            1. **Math Supplementary Class** (7/21 ~ 7/25, 9 AM ~ 11 AM)
            2. **English Camp** (7/28 ~ 8/1, 9 AM ~ 12 PM)
            3. **Reading Class** (8/4 ~ 8/8, 10 AM ~ 12 PM)

            ## Guidelines

            - Maintain a regular daily routine
            - Follow water safety rules
            - Read at least 30 minutes per day

            ## Assignments

            - 5 book reports
            - At least 10 diary entries

            Have a wonderful vacation!

            Thank you.
          MARKDOWN
        }
      },
      {
        original_file: "운동회 안내문 원본",
        uploaded_at: Time.current - 4.days,
        ko: {
          title: "2026학년도 가을 운동회 안내",
          content: <<~MARKDOWN
            # 2026학년도 가을 운동회 안내

            안녕하세요, 학부모님께.

            현풍초등학교 가을 운동회를 아래와 같이 개최합니다.

            ## 행사 일정

            - **날짜**: 2026년 10월 10일 (금)
            - **시간**: 오전 9시 ~ 오후 1시
            - **장소**: 학교 운동장

            ## 주요 프로그램

            1. 학년별 달리기 (100m)
            2. 줄다리기
            3. 이어달리기
            4. 학부모 참여 경기 (공 굴리기)
            5. 응원전

            ## 유의사항

            - 편한 운동복과 운동화 착용
            - 개인 물통 및 돗자리 지참
            - 우천 시 체육관에서 축소 진행

            학부모님의 많은 응원 부탁드립니다!

            감사합니다.
          MARKDOWN
        },
        en: {
          title: "2026 Fall Sports Day",
          content: <<~MARKDOWN
            # 2026 Fall Sports Day

            Dear Parents,

            Hyeonpung Elementary School will hold the annual Fall Sports Day.

            ## Event Schedule

            - **Date**: October 10, 2026 (Friday)
            - **Time**: 9:00 AM ~ 1:00 PM
            - **Location**: School Playground

            ## Main Events

            1. Grade-level 100m Race
            2. Tug of War
            3. Relay Race
            4. Parent Participation Event (Ball Rolling)
            5. Cheer Competition

            ## Important Notes

            - Wear comfortable sportswear and sneakers
            - Bring a personal water bottle and picnic blanket
            - In case of rain, the event will be held in a reduced format in the gymnasium

            We look forward to your support and cheering!

            Thank you.
          MARKDOWN
        }
      },
      {
        original_file: "급식 안내문 원본",
        uploaded_at: Time.current - 1.day,
        ko: {
          title: "3월 급식 안내 및 알레르기 조사",
          content: <<~MARKDOWN
            # 3월 급식 안내 및 알레르기 조사

            안녕하세요, 학부모님께.

            현풍초등학교 3월 급식 운영 안내 및 알레르기 조사를 실시합니다.

            ## 급식 안내

            - **급식 시작일**: 2026년 3월 4일(화)
            - **급식비**: 무상급식 (전액 지원)
            - **급식 시간**: 12시 ~ 1시

            ## 알레르기 조사

            아래 항목 중 자녀에게 해당하는 알레르기가 있으면 표시해 주세요:

            1. 난류 (계란)
            2. 우유
            3. 메밀
            4. 땅콩
            5. 대두 (콩)
            6. 밀
            7. 새우
            8. 게
            9. 돼지고기
            10. 복숭아

            ## 제출 기한

            - **기한**: 2026년 2월 28일(금)까지
            - 담임 선생님께 제출

            감사합니다.
          MARKDOWN
        },
        en: {
          title: "March School Lunch & Allergy Survey",
          content: <<~MARKDOWN
            # March School Lunch & Allergy Survey

            Dear Parents,

            Hyeonpung Elementary School will begin the March lunch service and is conducting an allergy survey.

            ## Lunch Information

            - **Start Date**: March 4, 2026 (Tuesday)
            - **Cost**: Free lunch (fully subsidized)
            - **Lunch Time**: 12:00 PM ~ 1:00 PM

            ## Allergy Survey

            Please indicate if your child has any of the following allergies:

            1. Eggs
            2. Milk
            3. Buckwheat
            4. Peanuts
            5. Soybeans
            6. Wheat
            7. Shrimp
            8. Crab
            9. Pork
            10. Peach

            ## Submission Deadline

            - **Deadline**: February 28, 2026 (Friday)
            - Submit to the homeroom teacher

            Thank you.
          MARKDOWN
        }
      }
    ]
  },
  gyeongbuk_school => {
    admin: admin_gyeongbuk,
    docs: [
      {
        original_file: "입학식 안내문 원본",
        uploaded_at: Time.current - 12.days,
        ko: {
          title: "2026학년도 입학식 안내",
          content: <<~MARKDOWN
            # 2026학년도 입학식 안내

            안녕하세요, 학부모님께.

            포항원동초등학교 2026학년도 입학식을 안내드립니다.

            ## 입학식 일정

            - **날짜**: 2026년 3월 3일 (월요일)
            - **시간**: 오전 10시
            - **장소**: 본교 강당

            ## 당일 일정

            | 시간 | 내용 |
            |------|------|
            | 09:30 | 등교 및 교실 안내 |
            | 10:00 | 입학식 (강당) |
            | 10:40 | 학급별 담임 인사 |
            | 11:00 | 하교 |

            ## 준비물

            - 실내화
            - 필기도구

            ## 학부모 안내

            - 보호자 1인 참석 가능
            - 주차 공간이 제한되오니 대중교통 이용 권장

            감사합니다.
          MARKDOWN
        },
        en: {
          title: "2026 Entrance Ceremony Notice",
          content: <<~MARKDOWN
            # 2026 Entrance Ceremony Notice

            Dear Parents,

            We are pleased to invite you to the 2026 entrance ceremony at Pohang Wondong Elementary School.

            ## Ceremony Schedule

            - **Date**: March 3, 2026 (Monday)
            - **Time**: 10:00 AM
            - **Location**: School Auditorium

            ## Day Schedule

            | Time | Activity |
            |------|----------|
            | 09:30 | Arrival & Classroom Guidance |
            | 10:00 | Entrance Ceremony (Auditorium) |
            | 10:40 | Homeroom Teacher Introduction |
            | 11:00 | Dismissal |

            ## What to Bring

            - Indoor shoes
            - Writing supplies

            ## For Parents

            - One guardian may attend
            - Parking is limited; public transportation is recommended

            Thank you.
          MARKDOWN
        }
      },
      {
        original_file: "현장학습 안내문 원본",
        uploaded_at: Time.current - 6.days,
        ko: {
          title: "경주 역사 현장학습 안내",
          content: <<~MARKDOWN
            # 경주 역사 현장학습 안내

            안녕하세요, 학부모님께.

            포항원동초등학교에서 경주 역사 현장학습을 실시합니다.

            ## 일정

            - **날짜**: 2026년 5월 8일 (목요일)
            - **시간**: 오전 8시 ~ 오후 5시
            - **장소**: 경주 불국사, 석굴암, 국립경주박물관

            ## 참가비

            - 1인당 15,000원 (버스비, 입장료 포함)
            - 납부 기한: 5월 2일(금)까지

            ## 준비물

            1. 도시락 및 간식
            2. 편한 운동화
            3. 필기도구 및 메모장
            4. 우산 또는 우비

            ## 유의사항

            - 오전 7시 50분까지 학교 정문 앞 집합
            - 문화재 보호를 위해 뛰지 않기
            - 안내 선생님의 지시에 따르기

            감사합니다.
          MARKDOWN
        },
        en: {
          title: "Gyeongju History Field Trip",
          content: <<~MARKDOWN
            # Gyeongju History Field Trip

            Dear Parents,

            Pohang Wondong Elementary School will conduct a history field trip to Gyeongju.

            ## Schedule

            - **Date**: May 8, 2026 (Thursday)
            - **Time**: 8:00 AM ~ 5:00 PM
            - **Locations**: Bulguksa Temple, Seokguram Grotto, Gyeongju National Museum

            ## Fee

            - 15,000 KRW per student (includes bus fare and admission)
            - Payment deadline: May 2 (Friday)

            ## What to Bring

            1. Packed lunch and snacks
            2. Comfortable sneakers
            3. Writing supplies and notebook
            4. Umbrella or raincoat

            ## Important Notes

            - Gather at the school front gate by 7:50 AM
            - Do not run near cultural heritage sites
            - Follow the teacher's instructions at all times

            Thank you.
          MARKDOWN
        }
      },
      {
        original_file: "방과후 프로그램 안내문 원본",
        uploaded_at: Time.current - 3.days,
        ko: {
          title: "2026학년도 1학기 방과후 프로그램 안내",
          content: <<~MARKDOWN
            # 2026학년도 1학기 방과후 프로그램 안내

            안녕하세요, 학부모님께.

            포항원동초등학교 1학기 방과후 프로그램 수강생을 모집합니다.

            ## 개설 프로그램

            | 프로그램 | 요일 | 시간 | 수강료 (월) |
            |----------|------|------|-------------|
            | 로봇코딩 | 월, 수 | 14:00~15:30 | 30,000원 |
            | 미술 | 화, 목 | 14:00~15:30 | 25,000원 |
            | 축구 | 월, 금 | 15:00~16:30 | 20,000원 |
            | 바이올린 | 수, 금 | 14:00~15:00 | 35,000원 |

            ## 신청 방법

            1. 가정통신문 하단 신청서 작성
            2. 희망 프로그램 2개까지 선택 가능
            3. 신청 기한: 3월 10일(월)까지

            ## 유의사항

            - 최소 인원(8명) 미달 시 폐강될 수 있음
            - 수강료는 매월 10일까지 납부
            - 중도 포기 시 잔여 수강료 환불 가능

            많은 관심 부탁드립니다.

            감사합니다.
          MARKDOWN
        },
        en: {
          title: "2026 First Semester After-School Programs",
          content: <<~MARKDOWN
            # 2026 First Semester After-School Programs

            Dear Parents,

            Pohang Wondong Elementary School is now accepting applications for after-school programs.

            ## Available Programs

            | Program | Days | Time | Fee (Monthly) |
            |---------|------|------|---------------|
            | Robot Coding | Mon, Wed | 2:00~3:30 PM | 30,000 KRW |
            | Art | Tue, Thu | 2:00~3:30 PM | 25,000 KRW |
            | Soccer | Mon, Fri | 3:00~4:30 PM | 20,000 KRW |
            | Violin | Wed, Fri | 2:00~3:00 PM | 35,000 KRW |

            ## How to Apply

            1. Fill out the application form at the bottom of this notice
            2. You may select up to 2 programs
            3. Application deadline: March 10 (Monday)

            ## Notes

            - Programs may be cancelled if fewer than 8 students enroll
            - Monthly fees are due by the 10th of each month
            - Remaining fees can be refunded upon withdrawal

            We look forward to your interest!

            Thank you.
          MARKDOWN
        }
      }
    ]
  }
}

# =============================================================================
# 안내장 생성
# =============================================================================
notices.each do |school, data|
  data[:docs].each do |doc_data|
    original_doc = OriginalDoc.find_or_create_by!(
      school: school,
      uploader: data[:admin],
      original_file: doc_data[:original_file]
    ) do |doc|
      doc.uploaded_at = doc_data[:uploaded_at]
      doc.status = :completed
    end

    Doc.find_or_create_by!(original_doc: original_doc, language: "ko") do |doc|
      doc.title = doc_data[:ko][:title]
      doc.content = doc_data[:ko][:content]
    end

    Doc.find_or_create_by!(original_doc: original_doc, language: "en") do |doc|
      doc.title = doc_data[:en][:title]
      doc.content = doc_data[:en][:content]
    end
  end
end

puts "Seed data created successfully!"
puts "Schools: #{School.count}"
puts "Users: #{User.count}"
puts "Original Docs: #{OriginalDoc.count}"
puts "Docs: #{Doc.count}"
puts ""
puts "Admin logins:"
puts "  제주 중앙초등학교: admin@jungangcho.kr / password123"
puts "  대구 현풍초등학교: admin@hyeonpungcho.kr / password123"
puts "  경북 포항원동초등학교: admin@pohangwondongcho.kr / password123"
