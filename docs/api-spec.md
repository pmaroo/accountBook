# 가계부 앱 API/동작 명세

## 1. 문서 목적

이 문서는 현재 앱이 내부적으로 제공하는 주요 동작과 이후 외부 API 연동 시 맞춰야 할 인터페이스를 정리한다.

## 2. 앱 내부 액션 명세

### 2.1 거래 관리

#### 거래 추가

- 입력값
  - `title`
  - `amount`
  - `categoryId`
  - `type`
- 처리
  - 수동 거래를 생성한다.
  - 생성 시점의 현재 시간을 거래일로 저장한다.
  - `isAutoSynced = false`로 저장한다.

#### 거래 수정

- 입력값
  - `id`
  - `title`
  - `amount`
  - `categoryId`
  - `type`
- 처리
  - 해당 거래를 찾아 값 갱신 후 최신 날짜 순으로 재정렬한다.

#### 거래 삭제

- 입력값
  - `id`
- 처리
  - 일치하는 거래를 목록에서 제거한다.

### 2.2 카테고리 관리

#### 카테고리 추가

- 입력값
  - `name`
  - `monthlyBudget`
  - `isFixed`
- 처리
  - 색상과 아이콘은 내부 순환 규칙으로 자동 배정한다.

#### 카테고리 수정

- 입력값
  - `categoryId`
  - `name`
  - `monthlyBudget`
  - `isFixed`

#### 카테고리 삭제

- 입력값
  - `categoryId`
- 처리
  - 이미 사용 중인 거래가 있으면 삭제를 막는다.

### 2.3 목표 관리

#### 목표 수정

- 입력값
  - `goalId`
  - `targetAmount`
  - `currentAmount`

### 2.4 설정 관리

#### 앱 설정 수정

- 입력값
  - `autoSyncEnabled`
  - `savingsTipsEnabled`
  - `challengeReminderEnabled`
  - `challengeDailyTarget`

### 2.5 데이터 이동

#### 거래 CSV 내보내기

- 출력
  - `transactions_yyyy-mm-dd...csv`
- 컬럼
  - `id`
  - `title`
  - `amount`
  - `type`
  - `categoryId`
  - `date`
  - `sourceName`
  - `isAutoSynced`
  - `providerId`
  - `externalId`

#### 거래 CSV 가져오기

- 방식
  - 최신 파일 자동 선택
  - 파일 선택 직접 가져오기
- 중복 기준
  - 동일 `id`
  - 동일 `providerId + externalId`

#### 전체 백업 내보내기

- 출력
  - `backup_yyyy-mm-dd...json`
- 포함 데이터
  - categories
  - transactions
  - accounts
  - goals
  - syncProviders
  - settings

#### 전체 백업 복원

- 방식
  - 최신 파일 자동 복원
  - 파일 선택 직접 복원

### 2.6 알림

#### 로컬 알림 테스트 발송

- 입력값
  - 현재 스냅샷 기반 알림 메시지 목록
- 처리
  - 중요도별 알림 메시지를 기기 로컬 알림으로 발송한다.

### 2.7 연동 공급자 인증

#### 공급자 연결 on/off

- 입력값
  - `providerId`
  - `connected`
- 상태 전이
  - off 시 `disconnected`
  - on 시 권한 여부에 따라 `authorizationRequired` 또는 `connected`

#### 인증 요청 시작

- 입력값
  - `providerId`
- 상태 전이
  - `pendingConsent`

#### 권한 승인 반영

- 입력값
  - `providerId`
  - `grantTransactions`
  - `grantBalance`
  - `grantInvestments`
- 상태 전이
  - 권한 충분 시 `connected`
  - 부족 시 `permissionRequired`

#### 인증 오류 표시

- 입력값
  - `providerId`
  - `message`
- 상태 전이
  - `error`

#### 공급자 동기화

- 입력값
  - `providerId`
- 실행 조건
  - 자동 동기화 활성화
  - 공급자 연결됨
  - 권한 승인됨
  - 인증 상태 `connected`

## 3. 금융 커넥터 인터페이스 명세

현재 앱은 실 API 대신 더미 커넥터 구조를 사용한다.

### 인터페이스

```dart
abstract class FinanceConnector {
  String get providerId;
  Future<ConnectorPayload> sync(DateTime now);
}
```

### 응답 구조

```dart
class ConnectorPayload {
  final List<TransactionEntry> transactions;
  final List<LinkedAccount> accounts;
}
```

## 4. 향후 외부 API 명세 초안

### 4.1 인증 시작 API

- 목적
  - 금융사 인증 URL 또는 인증 세션 발급
- 요청 예시

```json
{
  "providerId": "toss_bank",
  "userId": "user_001",
  "scopes": ["transactions", "balance"]
}
```

- 응답 예시

```json
{
  "authorizationUrl": "https://example.com/oauth/authorize?...",
  "state": "auth_state_123",
  "expiresIn": 600
}
```

### 4.2 인증 콜백 처리 API

- 목적
  - 인가 코드 교환 및 토큰 저장

### 4.3 계좌/카드/투자 조회 API

- 목적
  - 거래 내역, 잔액, 평가금액 동기화

### 4.4 토큰 갱신 API

- 목적
  - 만료된 접근 토큰 재발급

## 5. 상태 코드 제안

### 연동 인증 상태

1. `disconnected`
2. `authorizationRequired`
3. `pendingConsent`
4. `permissionRequired`
5. `connected`
6. `error`

### 알림 중요도

1. `info`
2. `warning`
3. `critical`
