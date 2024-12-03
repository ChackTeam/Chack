# 📚 Welcome to CHACK GitHub

[![GitHub Stars](https://img.shields.io/github/stars/ChackTeam/Chack?style=social)](https://github.com/ChackTeam/Chack)  
[![Flutter](https://img.shields.io/badge/Flutter-3.19.3-blue.svg)](https://flutter.dev)  
[![Dart](https://img.shields.io/badge/Dart-3.3.1-blue.svg)](https://dart.dev)  
[![Firebase](https://img.shields.io/badge/Firebase-latest-orange.svg)](https://firebase.google.com)  
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0.4-blue.svg)](https://www.typescriptlang.org/)

---

## 1. CHACK 소개

### 1.1 개요
**채크(CHACK)** 는 독서 습관 형성을 위한 모바일 애플리케이션입니다. 사용자는 자신의 서재에 도서를 추가하고, 독서 내용을 체계적으로 기록하며, 목표 설정을 통해 독서 활동을 효율적으로 관리할 수 있게 합니다.

**목표:**  
- 독서를 사용자 일상에 스며들게 하여 꾸준한 독서 습관 형성
- 독서를 통해 지식의 확장과 개인의 성장 도모

### 1.2 주요 기능
- 📖 개인 서재 관리  
- ⏱️ 독서 타이머  
- 📊 독서 통계 및 분석  
- 🎯 독서 목표 설정  
- 📝 독서 기록 및 메모  
- 📍 주변 도서관 찾기  
- 📚 도서 추천 시스템

> 💡 자세한 기능 설명은 [Wiki](./wiki)를 참고해주세요.

---

## 2. 기술 스택

| 항목 | 기술 스택 |
|------|-----------|
| **프레임워크** | Flutter 3.19.3 |
| **언어** | Dart 3.3.1 |
| **백엔드** | Firebase (Cloud Run, Functions) |
| **서버 언어** | TypeScript 5.0.4 |
| **상태관리** | Provider |
| **데이터베이스** | Cloud Firestore |
| **인증** | Firebase Authentication |
| **외부 API** | 도서관 정보나루, Naver 책 검색 API, VWorld API |

---

## 3. 시작하기

### 3.1 요구사항
- Flutter SDK 3.19.3 이상
- Dart SDK 3.3.1 이상
- Node.js 18.x 이상
- Firebase CLI
- Android Studio / VS Code

### 3.2 설치
```bash
# 저장소 클론
git clone https://github.com/ChackTeam/Chack.git
cd Chack

# 의존성 설치
flutter pub get

# iOS 의존성 설치
cd ios && pod install && cd ..
```
---

## 4. 프로젝트 구조
```
lib/
├── constants/      # 상수 및 테마
├── models/         # 데이터 모델
├── screens/        # UI 화면
├── services/       # 비즈니스 로직
├── utils/          # 유틸리티 함수
└── components/     # 재사용 가능한 위젯
```

---

## 5. Commit 규칙

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

## 6. 팀 소개

| Name | Role | Contact |
|------|------|----------|
| 강연수 | Frontend Developer | Email: yskang009@gmail.com<br>GitHub: [@mamemomif](https://github.com/mamemomif) |
| 문병진 | Frontend Developer | Email: qudwls5778@naver.com<br>GitHub: [@Moonbjin](https://github.com/Moonbjin) |
| 조현주 | UI/UX 설계 / Frontend Developer | Email: butter0488@gmail.com<br>GitHub: [@hjuump](https://github.com/hjuump) |
| 홍영준 | Frontend / Backend Developer | Email: moejihong@gmail.com<br>GitHub: [@HONGMOEJI](https://github.com/HONGMOEJI) |

---

## 7. 기여 가이드

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/AmazingFeature`
3. Commit your changes: `git commit -m 'feat: Add some AmazingFeature'`
4. Push to the branch: `git push origin feature/AmazingFeature`
5. Open a Pull Request

---

## 8. 문의하기

프로젝트에 대한 문의사항이나 버그 리포트는 [Issues](https://github.com/ChackTeam/Chack/issues)에 등록해주세요.

<p align="center">Made with ❤️ by CHACK Team</p>

---

### ⭐️ 이 프로젝트가 마음에 드셨다면, Star를 눌러주세요!
