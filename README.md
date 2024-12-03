
---

# 📚 Welcome to CHACK GitHub

[![GitHub Stars](https://img.shields.io/github/stars/ChackTeam/Chack?style=social)](https://github.com/ChackTeam/Chack)  
[![Flutter](https://img.shields.io/badge/Flutter-3.19.3-blue.svg)](https://flutter.dev)  
[![Dart](https://img.shields.io/badge/Dart-3.3.1-blue.svg)](https://dart.dev)  
[![Firebase](https://img.shields.io/badge/Firebase-latest-orange.svg)](https://firebase.google.com)  
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0.4-blue.svg)](https://www.typescriptlang.org/)

---

## 1. CHACK 소개

### 1.1 개요
**채크(CHACK)** 는 독서 습관 형성을 위한 모바일 애플리케이션입니다. 사용자가 자신의 서재에 책을 추가하고 읽은 내용을 기록하며, 목표 설정을 통해 독서 활동을 체계적으로 관리할 수 있게 합니다.  
또한, 시간 관리 기능을 제공하여 독서 시간을 효율적으로 활용할 수 있도록 돕습니다.

**목표:**  
- 독서를 사용자 일상에 스며들게 하여 꾸준한 독서 습관 형성
- 독서를 통해 지식의 확장과 개인의 성장 도모  

---

### 1.2 주요 기능
- 📖 개인 서재 관리  
- ⏱️ 독서 타이머  
- 📊 독서 통계 및 분석  
- 🎯 독서 목표 설정  
- 📝 독서 기록 및 메모  
- 📍 주변 도서관 찾기  
- 📚 도서 추천 시스템  

---

## 2. 기술 스택

| 항목       | 기술 스택                                                                                 |
|------------|-------------------------------------------------------------------------------------------|
| **프레임워크** | <img src="https://www.vectorlogo.zone/logos/flutterio/flutterio-icon.svg" width="30" height="30"/> Flutter 3.19.3 |
| **언어**     | <img src="https://www.vectorlogo.zone/logos/dartlang/dartlang-icon.svg" width="60" height="30"/> Dart 3.3.1  |
| **백엔드**    | <img src="https://www.vectorlogo.zone/logos/firebase/firebase-icon.svg" width="30" height="30"/> Firebase (Cloud Run, Functions) |
| **서버 언어** | <img src="https://www.vectorlogo.zone/logos/typescriptlang/typescriptlang-icon.svg" width="30" height="30"/> TypeScript 5.0.4 |
| **상태관리**  | Provider                                                                                |
| **데이터베이스** | Cloud Firestore                                                                        |
| **인증**     | Firebase Authentication                                                                 |
| **외부 API**  | 도서관 정보나루, Naver 책 검색 API, VWorld API                                            |

---

## 3. 주요 Dependencies

### 3.1 Flutter Dependencies
| **카테고리** | 패키지                                                                                           | 버전   | 설명                    |
|--------------|------------------------------------------------------------------------------------------------|--------|-------------------------|
| **상태관리** | [provider](https://pub.dev/packages/provider)                                                  | ^6.1.1 | 상태 관리 패키지         |
| **Firebase** | [firebase_core](https://pub.dev/packages/firebase_core)                                        | ^2.32.0 | Firebase Core 기능       |
|              | [firebase_auth](https://pub.dev/packages/firebase_auth)                                        | ^4.15.3 | Firebase 인증           |
|              | [cloud_firestore](https://pub.dev/packages/cloud_firestore)                                    | ^4.17.5 | Cloud Firestore         |
|              | [firebase_storage](https://pub.dev/packages/firebase_storage)                                  | ^11.2.0 | Firebase Storage        |
| **UI/UX**    | [flutter_svg](https://pub.dev/packages/flutter_svg)                                            | ^2.0.9  | SVG 렌더링 패키지       |
|              | [percent_indicator](https://pub.dev/packages/percent_indicator)                                | ^4.2.2 | 진행률 표시 위젯         |
|              | [fl_chart](https://pub.dev/packages/fl_chart)                                                  | ^0.65.0 | 차트 위젯               |
|              | [table_calendar](https://pub.dev/packages/table_calendar)                                      | ^3.0.10 | 캘린더 위젯             |
| **데이터저장**| [shared_preferences](https://pub.dev/packages/shared_preferences)                              | ^2.2.0  | 로컬 데이터 저장        |
|              | [hive](https://pub.dev/packages/hive)                                                          | ^2.2.3 | NoSQL 데이터베이스       |
|              | [hive_flutter](https://pub.dev/packages/hive_flutter)                                          | ^1.1.0  | Hive for Flutter        |
| **위치정보**  | [geolocator](https://pub.dev/packages/geolocator)                                              | ^8.0.0  | 위치 기반 서비스         |
|              | [geocoding](https://pub.dev/packages/geocoding)                                                | ^2.1.0  | 위치 정보 변환          |

### 3.2 백엔드 Dependencies
| 패키지              | 버전   | 설명                      |
|---------------------|--------|---------------------------|
| **TypeScript & Node.js** |
| typescript          | ^5.0.4 | TypeScript 컴파일러        |
| ts-node             | ^10.9.1| TypeScript 실행 환경       |
| @types/node         | ^18.15.11 | Node.js 타입 정의        |
| **Firebase**        | firebase-admin | ^11.5.0 | Firebase 관리자 SDK |
|                    | firebase-functions | ^4.2.1 | Cloud Functions SDK |
| **HTTP 클라이언트**  | axios | ^1.3.4 | HTTP 요청 처리         |
| **환경설정**         | dotenv | ^16.0.3 | 환경 변수 관리         |

---

## 4. 설치 및 설정 가이드

### 4.1 요구사항
- Flutter SDK 3.19.3 이상  
- Dart SDK 3.3.1 이상  
- Node.js 18.x 이상  
- Firebase CLI  
- Android Studio / VS Code  

### 4.2 설치 및 실행
1. **저장소 클론**  
   ```bash
   git clone https://github.com/CHACK-team/CHACK-project.git
   cd CHACK-project
   ```

2. **Flutter 의존성 설치**  
   ```bash
   flutter pub get
   ```

3. **Firebase 설정 파일 추가**
   - `google-services.json` (Android): `android/app/` 디렉토리에 추가  
   - `GoogleService-Info.plist` (iOS): Xcode 프로젝트에 추가  

4. **환경 변수 파일 생성**  
   `.env` 파일을 프로젝트 루트 디렉토리에 추가:  
   ```
   NAVER_CLIENT_ID=your_naver_client_id
   NAVER_CLIENT_SECRET=your_naver_client_secret
   LIBRARY_DATANARU_API_KEY=your_library_datanaru_api_key
   VWORLD_API_KEY=your_vworld_api_key
   ```

5. **앱 실행**  
   ```bash
   flutter run
   ```

6. **Firebase Functions 설정**  
   ```bash
   cd functions
   npm install
   ```

---

## 5. API 명세

### 5.1 엔드포인트
- **도서관 검색**  
  `GET /api/libraries`  
  **Query Parameters:**  
  - isbn: string  
  - latitude: number  
  - longitude: number  

- **인기 도서 조회**  
  `GET /api/hot-books`  
  **Query Parameters:**  
  - ageGroup: string  

---

## 6. Commit 규칙

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 주요 커밋 타입
- `feat`: 새로운 기능 추가  
- `fix`: 버그 수정  
- `docs`: 문서 변경  
- `style`: 코드 형식 변경  
- `refactor`: 코드 리팩토링  
- `test`: 테스트 추가 및 수정  

---

## 7. 팀 소개

| Name      | Role                   | Contact                                   |
|-----------|------------------------|------------------------------------------|
| 강연수     | Frontend Developer     | Email: yskang009@gmail.com<br>GitHub: [@mamemomif](https://github.com/mamemomif) |
| 문병진     | Frontend Developer     | Email: qudwls5778@naver.com<br>GitHub: [@Moonbjin](https://github.com/Moonbjin) |
| 조현주     | UX/UI Design / Frontend  | Email: butter0488@gmail.com<br>GitHub: [@hjuump](https://github.com/hjuump) |
| 홍영준     | Backend Developer      | Email: moejihong@gmail.com<br>GitHub: [@HONGMOEJI](https://github.com/HONGMOEJI) |

---

## 8. 기여

 가이드

1. Fork the repository  
2. Create your feature branch: `git checkout -b feature/AmazingFeature`  
3. Commit your changes: `git commit -m 'feat: Add some AmazingFeature'`  
4. Push to the branch: `git push origin feature/AmazingFeature`  
5. Open a Pull Request  

---

## 9. 문의하기
프로젝트에 대한 문의사항이나 버그 리포트는 [Issues](https://github.com/ChackTeam/Chack/issues)에 등록해주세요.

<p align="center">Made with ❤️ by CHACK Team</p>

--- 

### ⭐️ 이 프로젝트가 마음에 드셨다면, Star를 눌러주세요!
