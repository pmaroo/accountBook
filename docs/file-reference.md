# 가계부 앱 파일 레퍼런스

## 1. 문서 목적

이 문서는 현재 프로젝트의 주요 파일과 생성 파일이 어떤 역할을 가지는지 빠르게 찾을 수 있도록 정리한 파일 안내서다.

## 2. 루트 파일

### `README.md`

- 프로젝트 소개와 기본 실행 명령 안내

### `analysis_options.yaml`

- Flutter lints 기반 정적 분석 설정

### `pubspec.yaml`

- 앱 이름, 버전, 의존성, Flutter 설정 정의

### `pubspec.lock`

- 실제 해석된 패키지 버전 고정 파일

### `.gitignore`

- Git 추적 제외 파일 목록

### `.metadata`

- Flutter 도구용 프로젝트 메타데이터

### `fittheweb_household.iml`

- IDE 프로젝트 모듈 파일

## 3. 문서 파일

### `docs/screen-spec.md`

- 화면 정의서

### `docs/implemented-features.md`

- 구현 완료 기능 정리

### `docs/api-spec.md`

- 내부 액션 및 향후 외부 API 명세

### `docs/db-design.md`

- 로컬 저장 구조와 DB 설계 정리

### `docs/development-roadmap.md`

- 다음 개발 단계 로드맵

### `docs/admin-web-spec.md`

- 관리자 웹 분리 설계서

## 4. Flutter 앱 진입 파일

### `lib/main.dart`

- 앱 진입점
- `MoneyBookApp` 실행

### `lib/app/app.dart`

- MaterialApp 구성
- 하단 탭 셸 구성
- 공통 다이얼로그/바텀시트 함수 포함

### `lib/app/app_controller.dart`

- 앱 전역 상태 컨트롤러
- 거래, 카테고리, 목표, 연동, 백업/복원, 알림 관련 핵심 로직 담당

### `lib/app/theme/app_theme.dart`

- 앱 공통 테마 정의

## 5. 핵심 유틸

### `lib/core/utils/formatters.dart`

- 금액, 날짜 등 공통 포맷 함수 제공

## 6. 로컬 저장 파일

### `lib/data/local/app_persisted_state.dart`

- 앱 전체 상태 묶음 모델
- JSON 백업/복원 직렬화 담당

### `lib/data/local/app_storage_base.dart`

- 저장소 공통 인터페이스

### `lib/data/local/app_storage.dart`

- 플랫폼별 저장소 export 분기

### `lib/data/local/app_storage_io.dart`

- 모바일/데스크톱 SQLite 저장소 구현

### `lib/data/local/app_storage_web.dart`

- 웹 SharedPreferences 저장소 구현

### `lib/data/local/memory_app_storage.dart`

- 테스트용 메모리 저장소

## 7. 데이터 모델 파일

### `lib/data/models/finance_models.dart`

- 거래, 카테고리, 자산, 목표, 연동 공급자, 설정, 대시보드 스냅샷 등 핵심 도메인 모델 정의

## 8. 데이터 생성/계산 파일

### `lib/data/repositories/mock_finance_repository.dart`

- 샘플 데이터 생성
- 홈/통계용 계산 스냅샷 생성

## 9. 서비스 파일

### `lib/data/services/export_service.dart`

- 플랫폼별 내보내기/가져오기 서비스 export 분기

### `lib/data/services/export_service_base.dart`

- CSV/백업 입출력 서비스 인터페이스

### `lib/data/services/export_service_io.dart`

- 모바일/데스크톱 CSV 저장, CSV 가져오기, 백업 저장/복원 구현

### `lib/data/services/export_service_web.dart`

- 웹용 CSV/백업 읽기 처리와 웹 제한 대응 구현

### `lib/data/services/finance_connectors.dart`

- 금융 공급자 커넥터 인터페이스와 더미 구현체 정의

### `lib/data/services/local_alert_service.dart`

- 플랫폼별 로컬 알림 서비스 export 분기

### `lib/data/services/local_alert_service_base.dart`

- 로컬 알림 서비스 인터페이스

### `lib/data/services/local_alert_service_io.dart`

- 모바일/데스크톱 로컬 알림 발송 구현

### `lib/data/services/local_alert_service_web.dart`

- 웹 환경용 no-op 알림 처리

### `lib/data/services/notification_service.dart`

- 스냅샷 기반 알림 메시지 생성

## 10. 기능 화면 파일

### `lib/features/home/home_screen.dart`

- 홈 대시보드 화면

### `lib/features/transactions/transactions_screen.dart`

- 거래 목록, 필터, 상세, CSV 액션 화면

### `lib/features/assets/assets_screen.dart`

- 자산/저축/투자 현황 화면

### `lib/features/statistics/statistics_screen.dart`

- 월별 추세와 카테고리 통계 화면

### `lib/features/settings/settings_screen.dart`

- 알림, 카테고리, 백업/복원, 연동 진입 등 설정 화면

### `lib/features/settings/link_management_screen.dart`

- 금융 연동 인증 관리 전용 화면

## 11. 테스트 파일

### `test/widget_test.dart`

- 앱 셸 렌더링 기본 검증
- 테스트 저장소와 mock shared preferences 사용

## 12. Android 플랫폼 파일

### `android/app/build.gradle.kts`

- Android 앱 모듈 빌드 설정

### `android/build.gradle.kts`

- Android 전체 Gradle 설정

### `android/settings.gradle.kts`

- Android Gradle 프로젝트 설정

### `android/gradle.properties`

- Gradle 속성 설정

### `android/local.properties`

- 로컬 SDK 경로 등 개발 환경 값

### `android/gradlew`
### `android/gradlew.bat`

- Gradle wrapper 실행 스크립트

### `android/.gitignore`

- Android 빌드 산출물 제외 설정

### `android/fittheweb_household_android.iml`

- Android IDE 모듈 파일

## 13. iOS 플랫폼 파일

### `ios/Runner/AppDelegate.swift`

- iOS 앱 시작점

### `ios/Runner/Info.plist`

- iOS 앱 설정 plist

### `ios/Runner/GeneratedPluginRegistrant.h`
### `ios/Runner/GeneratedPluginRegistrant.m`

- Flutter 플러그인 자동 등록 파일

### `ios/Runner/Runner-Bridging-Header.h`

- Swift/Objective-C 브리징 헤더

### `ios/Runner.xcodeproj/project.pbxproj`

- iOS Xcode 프로젝트 설정

### `ios/Runner.xcworkspace/contents.xcworkspacedata`

- iOS workspace 구성

### `ios/RunnerTests/RunnerTests.swift`

- iOS 테스트 기본 파일

### `ios/Flutter/AppFrameworkInfo.plist`
### `ios/Flutter/Debug.xcconfig`
### `ios/Flutter/Generated.xcconfig`
### `ios/Flutter/Release.xcconfig`
### `ios/Flutter/flutter_export_environment.sh`

- Flutter iOS 빌드 설정 및 생성 파일

### `ios/.gitignore`

- iOS 빌드 산출물 제외 설정

## 14. macOS 플랫폼 파일

### `macos/Runner/AppDelegate.swift`

- macOS 앱 시작점

### `macos/Runner/MainFlutterWindow.swift`

- macOS 메인 윈도우 구성

### `macos/Runner/Info.plist`

- macOS 앱 설정

### `macos/Runner/DebugProfile.entitlements`
### `macos/Runner/Release.entitlements`

- macOS 권한 및 샌드박스 설정

### `macos/Runner.xcodeproj/project.pbxproj`

- macOS Xcode 프로젝트 설정

### `macos/Runner.xcworkspace/contents.xcworkspacedata`

- macOS workspace 구성

### `macos/Flutter/Flutter-Debug.xcconfig`
### `macos/Flutter/Flutter-Release.xcconfig`
### `macos/Flutter/GeneratedPluginRegistrant.swift`

- Flutter macOS 빌드 및 플러그인 등록 파일

### `macos/RunnerTests/RunnerTests.swift`

- macOS 테스트 기본 파일

### `macos/.gitignore`

- macOS 빌드 산출물 제외 설정

## 15. 웹 플랫폼 파일

### `web/index.html`

- 웹 앱 진입 HTML

### `web/manifest.json`

- PWA 메타데이터

### `web/favicon.png`
### `web/icons/Icon-192.png`
### `web/icons/Icon-512.png`
### `web/icons/Icon-maskable-192.png`
### `web/icons/Icon-maskable-512.png`

- 웹 아이콘 리소스

## 16. IDE/도구 생성 파일

### `.idea/.gitignore`
### `.idea/libraries/Dart_SDK.xml`
### `.idea/libraries/KotlinJavaRuntime.xml`
### `.idea/markdown.xml`
### `.idea/modules.xml`
### `.idea/runConfigurations/main_dart.xml`
### `.idea/workspace.xml`

- IntelliJ/Android Studio 설정 파일

### `.dart_tool/dartpad/web_plugin_registrant.dart`
### `.dart_tool/package_config.json`
### `.dart_tool/package_graph.json`
### `.dart_tool/version`

- Dart/Flutter 도구 생성 파일

### `.flutter-plugins-dependencies`

- 설치된 Flutter 플러그인 의존성 메타데이터

## 17. 빌드 산출물

### `build/...`

- 실행/테스트 중 생성된 빌드 산출물
- 수동 편집 대상이 아님

## 18. 관리자 웹 파일

### `admin_web/index.html`

- 독립 관리자 웹 화면 진입 파일

### `admin_web/styles.css`

- 관리자 웹 전용 스타일

### `admin_web/app.js`

- 관리자 웹 상태 관리, 백업 JSON 입출력, 편집 로직

### `admin_web/README.md`

- 관리자 웹 실행 방법과 사용 흐름 안내

## 19. 참고

현재 파일 레퍼런스는 프로젝트의 주요 파일과 생성 파일을 역할 기준으로 정리한 문서다.
세부 코드 변경 이력은 Git 기준으로 관리하고, 기능 흐름은 별도 문서에서 관리하는 것을 권장한다.
