# 가계부 앱 DB 설계서

## 1. 문서 목적

이 문서는 현재 앱의 로컬 저장 구조와 주요 엔티티를 정리한다.
모바일/데스크톱은 SQLite, 웹은 SharedPreferences 기반 JSON 저장을 사용한다.

## 2. 저장 전략

### 모바일/데스크톱

- 저장소: SQLite
- 구현 위치: `lib/data/local/app_storage_io.dart`
- 특징:
  - 앱 전체 상태를 테이블별로 저장
  - 앱 시작 시 전체 로드
  - 상태 변경 시 전체 저장
  - 버전 업그레이드 시 마이그레이션 지원

### 웹

- 저장소: SharedPreferences
- 구현 위치: `lib/data/local/app_storage_web.dart`
- 특징:
  - 리스트와 객체를 JSON 문자열로 저장

## 3. 엔티티 정의

### 3.1 categories

목적:
예산 카테고리 관리

컬럼:

1. `id` TEXT PRIMARY KEY
2. `name` TEXT NOT NULL
3. `monthlyBudget` INTEGER NOT NULL
4. `isFixed` INTEGER NOT NULL
5. `colorValue` INTEGER NOT NULL
6. `iconCodePoint` INTEGER NOT NULL

### 3.2 transactions

목적:
거래 내역 저장

컬럼:

1. `id` TEXT PRIMARY KEY
2. `title` TEXT NOT NULL
3. `amount` INTEGER NOT NULL
4. `type` TEXT NOT NULL
5. `categoryId` TEXT NOT NULL
6. `date` TEXT NOT NULL
7. `sourceName` TEXT NOT NULL
8. `isAutoSynced` INTEGER NOT NULL
9. `providerId` TEXT NULL
10. `externalId` TEXT NULL

중복 식별 규칙:

1. 내부 거래는 `id`
2. 외부 동기화 거래는 `providerId + externalId`

### 3.3 accounts

목적:
저축/투자 자산 저장

컬럼:

1. `id` TEXT PRIMARY KEY
2. `name` TEXT NOT NULL
3. `kind` TEXT NOT NULL
4. `principal` INTEGER NOT NULL
5. `currentBalance` INTEGER NOT NULL
6. `isLinked` INTEGER NOT NULL
7. `providerId` TEXT NULL

### 3.4 goals

목적:
저축 목표 저장

컬럼:

1. `id` TEXT PRIMARY KEY
2. `title` TEXT NOT NULL
3. `targetAmount` INTEGER NOT NULL
4. `currentAmount` INTEGER NOT NULL

### 3.5 sync_providers

목적:
금융 연동 공급자 상태 저장

컬럼:

1. `id` TEXT PRIMARY KEY
2. `name` TEXT NOT NULL
3. `type` TEXT NOT NULL
4. `isConnected` INTEGER NOT NULL
5. `hasPermission` INTEGER NOT NULL
6. `authStatus` TEXT NOT NULL
7. `lastSyncedAt` TEXT NULL
8. `statusMessage` TEXT NULL
9. `lastAuthorizedAt` TEXT NULL

인증 상태값:

1. `disconnected`
2. `authorizationRequired`
3. `pendingConsent`
4. `permissionRequired`
5. `connected`
6. `error`

### 3.6 settings

목적:
앱 설정 저장

컬럼:

1. `id` INTEGER PRIMARY KEY
2. `autoSyncEnabled` INTEGER NOT NULL
3. `savingsTipsEnabled` INTEGER NOT NULL
4. `challengeReminderEnabled` INTEGER NOT NULL
5. `challengeDailyTarget` INTEGER NOT NULL

## 4. 앱 전체 상태 구조

앱은 내부적으로 아래 상태 묶음을 사용한다.

1. `categories`
2. `transactions`
3. `accounts`
4. `goals`
5. `syncProviders`
6. `settings`

이 구조는 백업 JSON과 웹 저장 구조에서도 그대로 사용된다.

## 5. 마이그레이션 이력

### 버전 1

초기 테이블:

1. categories
2. transactions
3. accounts
4. goals
5. sync_providers
6. settings

### 버전 2

`sync_providers` 확장:

1. `authStatus` 추가
2. `statusMessage` 추가
3. `lastAuthorizedAt` 추가

기존 데이터 보정:

1. 연결 + 권한 있음 → `connected`
2. 연결만 있음 → `permissionRequired`
3. 둘 다 없음 → `disconnected`

## 6. 향후 DB 확장 추천

1. 사용자 계정 테이블
2. 인증 토큰 테이블
3. 알림 이력 테이블
4. 챌린지 로그 테이블
5. 목표 변경 이력 테이블
6. 카테고리별 통계 캐시 테이블

## 7. 인덱스/최적화 추천

현재는 앱 규모가 작아 단순 구조로 충분하지만, 이후 아래 인덱스를 권장한다.

1. `transactions(date)`
2. `transactions(categoryId)`
3. `transactions(providerId, externalId)`
4. `sync_providers(authStatus)`
