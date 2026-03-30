# FitTheWeb Admin Dashboard

앱과 분리된 운영자용 관리자 페이지입니다.
React + Next.js + shadcn/ui 기반으로 구성되어 있으며, 회원관리부터 통계까지 한 번에 볼 수 있도록 설계했습니다.

## 포함 기능

1. 회원 상태 모니터링
2. 월 소비/저축 통계
3. 예산 카테고리 검수
4. 금융 연동 상태 관리
5. 운영 정책 스위치 관리
6. 공지 초안 작성
7. 수동 검수 큐 시트

## 실행 방법

이 프로젝트는 로컬에 설치한 Node 20 바이너리 경로를 우선 사용하면 가장 안정적입니다.

```bash
cd /Users/bag-eunbi/fittheweb/app/admin-dashboard
export PATH=/Users/bag-eunbi/.local/node20/current/bin:$PATH
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## 검증 명령

```bash
export PATH=/Users/bag-eunbi/.local/node20/current/bin:$PATH
npm run lint
npm run build
```

## 주요 파일

1. `src/app/page.tsx`
2. `src/components/admin-dashboard.tsx`
3. `src/lib/admin-data.ts`
4. `src/app/globals.css`

## 메모

현재 화면은 운영용 샘플 데이터 기반입니다.
다음 단계에서는 실제 API, 인증, 사용자 데이터 저장소를 붙여서 실서비스 관리자 포털로 확장할 수 있습니다.
