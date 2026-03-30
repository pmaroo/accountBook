export type AdminMember = {
  id: string
  name: string
  email: string
  tier: "VIP" | "Standard" | "Watch"
  status: "active" | "pending" | "risk"
  joinedAt: string
  monthlySpend: number
  totalAssets: number
  savingsRate: number
  linkedProviders: number
}

export type AdminProvider = {
  id: string
  name: string
  type: "bank" | "card" | "investment" | "payment"
  status: "connected" | "pendingConsent" | "permissionRequired" | "error"
  users: number
  successRate: number
  lastIncident: string
}

export type BudgetLine = {
  id: string
  category: string
  budget: number
  spent: number
  owner: string
}

export const monthlyTrend = [
  { month: "1월", revenue: 6.2, spend: 4.5, savings: 1.7 },
  { month: "2월", revenue: 6.5, spend: 4.8, savings: 1.8 },
  { month: "3월", revenue: 6.8, spend: 5.1, savings: 1.7 },
  { month: "4월", revenue: 6.7, spend: 4.9, savings: 1.8 },
  { month: "5월", revenue: 7.0, spend: 5.3, savings: 1.7 },
  { month: "6월", revenue: 7.4, spend: 5.4, savings: 2.0 },
]

export const categoryShare = [
  { category: "식비", value: 31, fill: "var(--color-food)" },
  { category: "월세", value: 24, fill: "var(--color-rent)" },
  { category: "생활비", value: 18, fill: "var(--color-living)" },
  { category: "여행저축", value: 16, fill: "var(--color-travel)" },
  { category: "비상금", value: 11, fill: "var(--color-emergency)" },
]

export const members: AdminMember[] = [
  {
    id: "m-1001",
    name: "김서연",
    email: "seoyeon@fitweb.dev",
    tier: "VIP",
    status: "active",
    joinedAt: "2025-11-02",
    monthlySpend: 1840000,
    totalAssets: 12300000,
    savingsRate: 29,
    linkedProviders: 4,
  },
  {
    id: "m-1002",
    name: "박지우",
    email: "jiwoo@fitweb.dev",
    tier: "Standard",
    status: "active",
    joinedAt: "2026-01-12",
    monthlySpend: 1260000,
    totalAssets: 8400000,
    savingsRate: 24,
    linkedProviders: 3,
  },
  {
    id: "m-1003",
    name: "최유진",
    email: "yujin@fitweb.dev",
    tier: "Watch",
    status: "risk",
    joinedAt: "2026-02-18",
    monthlySpend: 2110000,
    totalAssets: 3900000,
    savingsRate: 6,
    linkedProviders: 2,
  },
  {
    id: "m-1004",
    name: "이하린",
    email: "harin@fitweb.dev",
    tier: "Standard",
    status: "pending",
    joinedAt: "2026-03-03",
    monthlySpend: 920000,
    totalAssets: 5100000,
    savingsRate: 18,
    linkedProviders: 1,
  },
]

export const providers: AdminProvider[] = [
  {
    id: "p-1",
    name: "토스뱅크",
    type: "bank",
    status: "connected",
    users: 824,
    successRate: 98.4,
    lastIncident: "없음",
  },
  {
    id: "p-2",
    name: "현대카드",
    type: "card",
    status: "connected",
    users: 642,
    successRate: 97.1,
    lastIncident: "3월 24일 지연 복구",
  },
  {
    id: "p-3",
    name: "미래에셋",
    type: "investment",
    status: "permissionRequired",
    users: 291,
    successRate: 88.6,
    lastIncident: "권한 재승인 증가",
  },
  {
    id: "p-4",
    name: "삼성페이",
    type: "payment",
    status: "pendingConsent",
    users: 411,
    successRate: 91.3,
    lastIncident: "동의 단계 대기 사용자 증가",
  },
]

export const budgets: BudgetLine[] = [
  { id: "b-1", category: "식비", budget: 300000, spent: 246000, owner: "전체 사용자 평균" },
  { id: "b-2", category: "월세", budget: 650000, spent: 650000, owner: "전체 사용자 평균" },
  { id: "b-3", category: "생활비", budget: 220000, spent: 175000, owner: "전체 사용자 평균" },
  { id: "b-4", category: "여행저축", budget: 180000, spent: 120000, owner: "전체 사용자 평균" },
  { id: "b-5", category: "비상금", budget: 150000, spent: 93000, owner: "전체 사용자 평균" },
]

export const adminSignals = [
  {
    title: "위험 사용자 모니터링",
    body: "이번 주 저축률 10% 미만 회원이 12명으로 늘었습니다. 식비 과소비와 카드 연동 오류가 동시에 나타납니다.",
  },
  {
    title: "연동 재승인 유도 필요",
    body: "미래에셋 투자 연동의 권한 만료 비율이 11%를 넘었습니다. 공지 배너와 재인증 알림을 우선 배치하세요.",
  },
  {
    title: "여행저축 전환 캠페인 적기",
    body: "3월 들어 식비를 줄인 사용자 그룹의 잔여 예산이 증가했습니다. 여행저축 전환 메시지 효과가 기대됩니다.",
  },
]

export const operationNotes = [
  "VIP 회원 자산 동기화 SLA를 99% 이상 유지",
  "고위험 회원군은 24시간 내 알림 반응 확인",
  "카드 승인 지연이 2시간 이상이면 운영 알럿 발송",
]
