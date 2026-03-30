"use client"

import * as React from "react"
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Pie,
  PieChart,
  XAxis,
} from "recharts"
import {
  AlertCircle,
  ArrowUpRight,
  BellRing,
  CreditCard,
  Database,
  LayoutDashboard,
  Link2,
  PieChartIcon,
  Search,
  Settings2,
  ShieldCheck,
  Users,
  Wallet,
} from "lucide-react"

import { members, providers, budgets, monthlyTrend, categoryShare, adminSignals, operationNotes } from "@/lib/admin-data"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Input } from "@/components/ui/input"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarInset,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarProvider,
  SidebarTrigger,
} from "@/components/ui/sidebar"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
  type ChartConfig,
} from "@/components/ui/chart"
import { Progress } from "@/components/ui/progress"
import { Separator } from "@/components/ui/separator"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Switch } from "@/components/ui/switch"
import { Textarea } from "@/components/ui/textarea"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet"

const financeChartConfig = {
  revenue: { label: "수입", color: "var(--chart-1)" },
  spend: { label: "지출", color: "var(--chart-2)" },
  savings: { label: "저축 가능", color: "var(--chart-3)" },
} satisfies ChartConfig

const categoryChartConfig = {
  value: { label: "비중" },
  food: { label: "식비", color: "var(--chart-1)" },
  rent: { label: "월세", color: "var(--chart-2)" },
  living: { label: "생활비", color: "var(--chart-3)" },
  travel: { label: "여행저축", color: "var(--chart-4)" },
  emergency: { label: "비상금", color: "var(--chart-5)" },
} satisfies ChartConfig

const providerChartConfig = {
  successRate: { label: "성공률", color: "var(--chart-1)" },
} satisfies ChartConfig

const navItems = [
  { label: "개요", icon: LayoutDashboard },
  { label: "회원관리", icon: Users },
  { label: "금융운영", icon: Wallet },
  { label: "연동상태", icon: Link2 },
  { label: "통계", icon: PieChartIcon },
  { label: "정책", icon: Settings2 },
]

export function AdminDashboard() {
  const [selectedMemberId, setSelectedMemberId] = React.useState<string | null>(members[0]?.id ?? null)
  const [memberQuery, setMemberQuery] = React.useState("")

  const selectedMember = members.find((member) => member.id === selectedMemberId) ?? members[0]
  const filteredMembers = members.filter((member) => {
    const query = memberQuery.trim().toLowerCase()
    if (!query) {
      return true
    }

    return (
      member.name.toLowerCase().includes(query) ||
      member.email.toLowerCase().includes(query) ||
      member.id.toLowerCase().includes(query)
    )
  })

  return (
    <SidebarProvider defaultOpen>
      <Sidebar variant="floating" collapsible="icon">
        <SidebarHeader className="gap-3 px-3 py-4">
          <div className="flex items-center gap-3 rounded-2xl border border-sidebar-border/70 bg-sidebar-accent/40 p-3">
            <div className="flex size-10 items-center justify-center rounded-2xl bg-sidebar-primary text-sidebar-primary-foreground shadow-sm">
              <ShieldCheck className="size-5" />
            </div>
            <div className="min-w-0 group-data-[collapsible=icon]:hidden">
              <p className="text-sm font-semibold">FitTheWeb HQ</p>
              <p className="text-xs text-sidebar-foreground/70">운영자 통합 콘솔</p>
            </div>
          </div>
        </SidebarHeader>
        <SidebarContent>
          <SidebarGroup>
            <SidebarGroupLabel>관리 메뉴</SidebarGroupLabel>
            <SidebarGroupContent>
              <SidebarMenu>
                {navItems.map((item) => (
                  <SidebarMenuItem key={item.label}>
                    <SidebarMenuButton isActive={item.label === "개요"} tooltip={item.label}>
                      <item.icon className="size-4" />
                      <span>{item.label}</span>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                ))}
              </SidebarMenu>
            </SidebarGroupContent>
          </SidebarGroup>

          <SidebarGroup>
            <SidebarGroupLabel>운영 신호</SidebarGroupLabel>
            <SidebarGroupContent>
              <div className="space-y-3 px-2">
                {adminSignals.map((signal) => (
                  <Card key={signal.title} className="rounded-2xl border-sidebar-border/70 bg-sidebar-accent/30 shadow-none">
                    <CardContent className="space-y-2 p-4">
                      <div className="flex items-center gap-2 text-sm font-semibold">
                        <BellRing className="size-4 text-primary" />
                        {signal.title}
                      </div>
                      <p className="text-xs leading-5 text-muted-foreground">{signal.body}</p>
                    </CardContent>
                  </Card>
                ))}
              </div>
            </SidebarGroupContent>
          </SidebarGroup>
        </SidebarContent>
        <SidebarFooter className="px-3 pb-4">
          <Card className="rounded-2xl border-sidebar-border/70 bg-sidebar-accent/30 shadow-none">
            <CardContent className="p-4">
              <p className="text-sm font-semibold">오늘의 운영 메모</p>
              <p className="mt-2 text-xs leading-5 text-muted-foreground">
                회원 저축률과 투자 연동 재승인 비율을 함께 확인하세요.
              </p>
            </CardContent>
          </Card>
        </SidebarFooter>
      </Sidebar>

      <SidebarInset className="bg-[radial-gradient(circle_at_top_right,rgba(14,165,233,0.10),transparent_28%),radial-gradient(circle_at_bottom_left,rgba(245,158,11,0.12),transparent_24%)]">
        <div className="flex min-h-svh flex-col">
          <header className="sticky top-0 z-20 border-b border-border/60 bg-background/80 px-4 py-3 backdrop-blur xl:px-8">
            <div className="flex flex-col gap-4 xl:flex-row xl:items-center xl:justify-between">
              <div className="flex items-center gap-3">
                <SidebarTrigger />
                <div>
                  <p className="text-sm font-medium text-primary">React + Next + shadcn/ui</p>
                  <h1 className="text-2xl font-semibold tracking-tight">회원관리부터 통계까지 한 번에 보는 운영 대시보드</h1>
                </div>
              </div>

              <div className="flex flex-col gap-3 md:flex-row md:items-center">
                <div className="relative min-w-[280px]">
                  <Search className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
                  <Input
                    value={memberQuery}
                    onChange={(event) => setMemberQuery(event.target.value)}
                    placeholder="회원명, 이메일, 회원 ID 검색"
                    className="pl-9"
                  />
                </div>
                <Select defaultValue="today">
                  <SelectTrigger className="w-[180px]">
                    <SelectValue placeholder="기간 선택" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="today">오늘 기준</SelectItem>
                    <SelectItem value="weekly">최근 7일</SelectItem>
                    <SelectItem value="monthly">최근 30일</SelectItem>
                  </SelectContent>
                </Select>
                <Button className="gap-2 rounded-full">
                  운영 리포트 내보내기
                  <ArrowUpRight className="size-4" />
                </Button>
              </div>
            </div>
          </header>

          <div className="flex-1 space-y-6 px-4 py-6 xl:px-8">
            <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
              <MetricCard
                title="활성 회원"
                value="12,480"
                description="전주 대비 +4.8%"
                icon={Users}
                tone="sky"
              />
              <MetricCard
                title="월 총 거래량"
                value="₩7.4억"
                description="수동 검수 대기 148건"
                icon={CreditCard}
                tone="emerald"
              />
              <MetricCard
                title="정상 연동률"
                value="94.2%"
                description="재승인 대상 83명"
                icon={Link2}
                tone="amber"
              />
              <MetricCard
                title="운영 경고"
                value="07건"
                description="위험 회원군 12명 포함"
                icon={AlertCircle}
                tone="rose"
              />
            </section>

            <section className="grid gap-6 xl:grid-cols-[1.5fr_1fr]">
              <Card className="rounded-3xl border-border/70 shadow-sm">
                <CardHeader className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
                  <div>
                    <CardDescription>Finance Overview</CardDescription>
                    <CardTitle className="text-xl">월간 수입 · 지출 · 저축 가능 흐름</CardTitle>
                  </div>
                  <Badge variant="secondary" className="rounded-full px-3 py-1">
                    운영용 합산 지표
                  </Badge>
                </CardHeader>
                <CardContent>
                  <ChartContainer config={financeChartConfig} className="h-[310px] w-full">
                    <AreaChart data={monthlyTrend}>
                      <defs>
                        <linearGradient id="fillRevenue" x1="0" x2="0" y1="0" y2="1">
                          <stop offset="5%" stopColor="var(--color-revenue)" stopOpacity={0.42} />
                          <stop offset="95%" stopColor="var(--color-revenue)" stopOpacity={0.05} />
                        </linearGradient>
                        <linearGradient id="fillSpend" x1="0" x2="0" y1="0" y2="1">
                          <stop offset="5%" stopColor="var(--color-spend)" stopOpacity={0.34} />
                          <stop offset="95%" stopColor="var(--color-spend)" stopOpacity={0.04} />
                        </linearGradient>
                      </defs>
                      <CartesianGrid vertical={false} />
                      <XAxis axisLine={false} dataKey="month" tickLine={false} />
                      <ChartTooltip content={<ChartTooltipContent />} cursor={false} />
                      <Area
                        dataKey="revenue"
                        type="natural"
                        fill="url(#fillRevenue)"
                        stroke="var(--color-revenue)"
                        strokeWidth={2}
                      />
                      <Area
                        dataKey="spend"
                        type="natural"
                        fill="url(#fillSpend)"
                        stroke="var(--color-spend)"
                        strokeWidth={2}
                      />
                      <Area
                        dataKey="savings"
                        type="natural"
                        fillOpacity={0}
                        stroke="var(--color-savings)"
                        strokeDasharray="6 4"
                        strokeWidth={2}
                      />
                    </AreaChart>
                  </ChartContainer>
                </CardContent>
              </Card>

              <Card className="rounded-3xl border-border/70 shadow-sm">
                <CardHeader>
                  <CardDescription>Category Share</CardDescription>
                  <CardTitle className="text-xl">지출 카테고리 비중</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <ChartContainer
                    config={categoryChartConfig}
                    className="mx-auto h-[250px] max-w-[360px]"
                  >
                    <PieChart>
                      <ChartTooltip content={<ChartTooltipContent hideLabel />} />
                      <Pie data={categoryShare} dataKey="value" innerRadius={64} outerRadius={98} paddingAngle={3}>
                        {categoryShare.map((item) => (
                          <Cell key={item.category} fill={item.fill} />
                        ))}
                      </Pie>
                    </PieChart>
                  </ChartContainer>
                  <div className="grid gap-3">
                    {categoryShare.map((item) => (
                      <div key={item.category} className="flex items-center justify-between rounded-2xl border border-border/60 bg-muted/30 px-4 py-3">
                        <div className="flex items-center gap-3">
                          <span className="size-3 rounded-full" style={{ backgroundColor: item.fill }} />
                          <span className="font-medium">{item.category}</span>
                        </div>
                        <Badge variant="outline" className="rounded-full">{item.value}%</Badge>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </section>

            <Tabs defaultValue="members" className="space-y-4">
              <TabsList className="h-auto flex-wrap rounded-2xl bg-muted/60 p-1">
                <TabsTrigger value="members" className="rounded-xl">회원관리</TabsTrigger>
                <TabsTrigger value="finance" className="rounded-xl">거래/예산</TabsTrigger>
                <TabsTrigger value="providers" className="rounded-xl">연동상태</TabsTrigger>
                <TabsTrigger value="ops" className="rounded-xl">운영설정</TabsTrigger>
              </TabsList>

              <TabsContent value="members" className="grid gap-6 xl:grid-cols-[1.25fr_0.85fr]">
                <Card className="rounded-3xl border-border/70 shadow-sm">
                  <CardHeader className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
                    <div>
                      <CardDescription>Member Operations</CardDescription>
                      <CardTitle className="text-xl">회원 상태와 자산 흐름 관리</CardTitle>
                    </div>
                    <Badge variant="outline" className="rounded-full px-3 py-1">
                      검색 결과 {filteredMembers.length}명
                    </Badge>
                  </CardHeader>
                  <CardContent>
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>회원</TableHead>
                          <TableHead>등급</TableHead>
                          <TableHead>상태</TableHead>
                          <TableHead>월 소비</TableHead>
                          <TableHead>저축률</TableHead>
                          <TableHead className="text-right">관리</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {filteredMembers.map((member) => (
                          <TableRow key={member.id}>
                            <TableCell className="py-4">
                              <div className="flex items-center gap-3">
                                <Avatar className="size-10">
                                  <AvatarFallback>{member.name.slice(0, 1)}</AvatarFallback>
                                </Avatar>
                                <div>
                                  <p className="font-medium">{member.name}</p>
                                  <p className="text-xs text-muted-foreground">{member.email}</p>
                                </div>
                              </div>
                            </TableCell>
                            <TableCell>
                              <Badge variant="secondary" className="rounded-full">{member.tier}</Badge>
                            </TableCell>
                            <TableCell>
                              <StatusBadge status={member.status} />
                            </TableCell>
                            <TableCell>{currency(member.monthlySpend)}</TableCell>
                            <TableCell>
                              <div className="space-y-2">
                                <div className="text-sm font-medium">{member.savingsRate}%</div>
                                <Progress value={member.savingsRate} className="h-2" />
                              </div>
                            </TableCell>
                            <TableCell className="text-right">
                              <DropdownMenu>
                                <DropdownMenuTrigger className="inline-flex h-8 items-center justify-center rounded-full border border-border bg-background px-3 text-sm font-medium shadow-xs transition-colors hover:bg-accent hover:text-accent-foreground">
                                  작업
                                </DropdownMenuTrigger>
                                <DropdownMenuContent align="end">
                                  <DropdownMenuItem onClick={() => setSelectedMemberId(member.id)}>
                                    상세 보기
                                  </DropdownMenuItem>
                                  <DropdownMenuItem>알림 발송</DropdownMenuItem>
                                  <DropdownMenuItem>권한 점검 요청</DropdownMenuItem>
                                </DropdownMenuContent>
                              </DropdownMenu>
                            </TableCell>
                          </TableRow>
                        ))}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>

                <Card className="rounded-3xl border-border/70 shadow-sm">
                  <CardHeader>
                    <CardDescription>Member Snapshot</CardDescription>
                    <CardTitle className="text-xl">선택 회원 상세</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-5">
                    <div className="flex items-center gap-4">
                      <Avatar className="size-14">
                        <AvatarFallback>{selectedMember.name.slice(0, 1)}</AvatarFallback>
                      </Avatar>
                      <div>
                        <h3 className="text-lg font-semibold">{selectedMember.name}</h3>
                        <p className="text-sm text-muted-foreground">{selectedMember.email}</p>
                      </div>
                    </div>
                    <Separator />
                    <div className="grid gap-4 sm:grid-cols-2">
                      <SnapshotStat label="회원 ID" value={selectedMember.id} />
                      <SnapshotStat label="가입일" value={selectedMember.joinedAt} />
                      <SnapshotStat label="총 자산" value={currency(selectedMember.totalAssets)} />
                      <SnapshotStat label="연동 수" value={`${selectedMember.linkedProviders}개`} />
                    </div>
                    <div className="rounded-2xl border border-border/60 bg-muted/25 p-4">
                      <p className="text-sm font-medium">운영 메모</p>
                      <p className="mt-2 text-sm leading-6 text-muted-foreground">
                        저축률과 월 소비 흐름을 함께 보며, 위험 사용자군은 재인증과 소비 카테고리 조정 메시지를 우선 검토합니다.
                      </p>
                    </div>
                    <Dialog>
                      <DialogTrigger className="inline-flex h-10 w-full items-center justify-center rounded-full border border-border bg-background px-4 text-sm font-medium shadow-xs transition-colors hover:bg-accent hover:text-accent-foreground">
                        회원 상세 대화상자 열기
                      </DialogTrigger>
                      <DialogContent className="sm:max-w-xl">
                        <DialogHeader>
                          <DialogTitle>{selectedMember.name} 운영 상세</DialogTitle>
                          <DialogDescription>
                            회원 상태, 자산, 운영 메모를 한곳에서 확인합니다.
                          </DialogDescription>
                        </DialogHeader>
                        <div className="grid gap-4">
                          <SnapshotStat label="월 소비" value={currency(selectedMember.monthlySpend)} />
                          <SnapshotStat label="저축률" value={`${selectedMember.savingsRate}%`} />
                          <SnapshotStat label="등급" value={selectedMember.tier} />
                          <Textarea
                            defaultValue="식비 과소비 경향이 있어 절약 플랜 메시지 빈도를 상향 조정합니다."
                            className="min-h-28"
                          />
                        </div>
                      </DialogContent>
                    </Dialog>
                  </CardContent>
                </Card>
              </TabsContent>

              <TabsContent value="finance" className="grid gap-6 xl:grid-cols-[1.2fr_0.8fr]">
                <Card className="rounded-3xl border-border/70 shadow-sm">
                  <CardHeader>
                    <CardDescription>Budget Operations</CardDescription>
                    <CardTitle className="text-xl">예산 사용률과 카테고리 검수</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {budgets.map((budget) => {
                      const rate = Math.round((budget.spent / budget.budget) * 100)

                      return (
                        <div key={budget.id} className="rounded-2xl border border-border/60 bg-muted/20 p-4">
                          <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
                            <div>
                              <p className="font-medium">{budget.category}</p>
                              <p className="text-sm text-muted-foreground">{budget.owner}</p>
                            </div>
                            <div className="text-right">
                              <p className="font-semibold">{currency(budget.spent)} / {currency(budget.budget)}</p>
                              <p className="text-sm text-muted-foreground">{rate}% 사용</p>
                            </div>
                          </div>
                          <Progress value={Math.min(rate, 100)} className="mt-4 h-2.5" />
                        </div>
                      )
                    })}
                  </CardContent>
                </Card>

                <Card className="rounded-3xl border-border/70 shadow-sm">
                  <CardHeader>
                    <CardDescription>Queue</CardDescription>
                    <CardTitle className="text-xl">수동 검수 대기 거래</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <Sheet>
                      <SheetTrigger className="inline-flex h-10 w-full items-center justify-center rounded-full bg-primary px-4 text-sm font-medium text-primary-foreground shadow-xs transition-colors hover:bg-primary/90">
                        검수 큐 자세히 보기
                      </SheetTrigger>
                      <SheetContent className="w-full sm:max-w-xl">
                        <SheetHeader>
                          <SheetTitle>거래 검수 대기열</SheetTitle>
                          <SheetDescription>
                            자동 분류가 애매한 거래를 우선 검수합니다.
                          </SheetDescription>
                        </SheetHeader>
                        <ScrollArea className="mt-6 h-[70vh] pr-4">
                          <div className="space-y-4">
                            {[
                              ["배달앱 결제", "식비", "자동 분류 신뢰도 61%"],
                              ["해외 결제", "여행저축", "환율 반영 확인 필요"],
                              ["현금 인출", "생활비", "카테고리 재배치 권장"],
                            ].map(([title, category, note]) => (
                              <Card key={title} className="rounded-2xl">
                                <CardContent className="space-y-2 p-4">
                                  <div className="flex items-center justify-between gap-3">
                                    <p className="font-medium">{title}</p>
                                    <Badge variant="outline" className="rounded-full">{category}</Badge>
                                  </div>
                                  <p className="text-sm text-muted-foreground">{note}</p>
                                  <div className="flex gap-2">
                                    <Button size="sm" variant="outline">보류</Button>
                                    <Button size="sm">승인</Button>
                                  </div>
                                </CardContent>
                              </Card>
                            ))}
                          </div>
                        </ScrollArea>
                      </SheetContent>
                    </Sheet>

                    <ChartContainer config={providerChartConfig} className="h-[220px]">
                      <BarChart data={providers}>
                        <CartesianGrid vertical={false} />
                        <XAxis axisLine={false} dataKey="name" tickLine={false} />
                        <ChartTooltip content={<ChartTooltipContent />} cursor={false} />
                        <Bar dataKey="successRate" fill="var(--color-successRate)" radius={12} />
                      </BarChart>
                    </ChartContainer>
                  </CardContent>
                </Card>
              </TabsContent>

              <TabsContent value="providers" className="grid gap-6 xl:grid-cols-[1.1fr_0.9fr]">
                <Card className="rounded-3xl border-border/70 shadow-sm">
                  <CardHeader>
                    <CardDescription>Provider Status</CardDescription>
                    <CardTitle className="text-xl">금융사 연동 현황</CardTitle>
                  </CardHeader>
                  <CardContent className="grid gap-4">
                    {providers.map((provider) => (
                      <Card key={provider.id} className="rounded-2xl border-border/60">
                        <CardContent className="space-y-4 p-5">
                          <div className="flex items-start justify-between gap-3">
                            <div>
                              <p className="text-sm text-muted-foreground">{provider.type}</p>
                              <h3 className="font-semibold">{provider.name}</h3>
                            </div>
                            <ProviderBadge status={provider.status} />
                          </div>
                          <div className="grid gap-3 sm:grid-cols-3">
                            <SnapshotStat label="연결 회원" value={`${provider.users}명`} />
                            <SnapshotStat label="성공률" value={`${provider.successRate}%`} />
                            <SnapshotStat label="최근 이슈" value={provider.lastIncident} />
                          </div>
                          <div className="flex items-center justify-between rounded-2xl border border-border/60 bg-muted/25 px-4 py-3">
                            <div>
                              <p className="text-sm font-medium">자동 재시도 사용</p>
                              <p className="text-xs text-muted-foreground">권한 만료 및 일시 장애 시 재시도</p>
                            </div>
                            <Switch defaultChecked={provider.status !== "error"} />
                          </div>
                        </CardContent>
                      </Card>
                    ))}
                  </CardContent>
                </Card>

                <Card className="rounded-3xl border-border/70 shadow-sm">
                  <CardHeader>
                    <CardDescription>Operation Notes</CardDescription>
                    <CardTitle className="text-xl">운영 체크리스트</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {operationNotes.map((note) => (
                      <div key={note} className="flex gap-3 rounded-2xl border border-border/60 bg-muted/25 p-4">
                        <div className="mt-1 flex size-8 items-center justify-center rounded-full bg-primary/10 text-primary">
                          <ShieldCheck className="size-4" />
                        </div>
                        <p className="text-sm leading-6 text-muted-foreground">{note}</p>
                      </div>
                    ))}
                  </CardContent>
                </Card>
              </TabsContent>

              <TabsContent value="ops" className="grid gap-6 xl:grid-cols-[1fr_0.95fr]">
                <Card className="rounded-3xl border-border/70 shadow-sm">
                  <CardHeader>
                    <CardDescription>Policy Controls</CardDescription>
                    <CardTitle className="text-xl">운영 정책 설정</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <PolicyRow
                      icon={Database}
                      title="백업 자동 생성"
                      description="일일 운영 백업을 생성하고 관리자에게 알림을 전송합니다."
                      defaultChecked
                    />
                    <PolicyRow
                      icon={BellRing}
                      title="위험 회원군 실시간 알림"
                      description="저축률 급감, 연동 오류, 소비 급증 사용자를 즉시 표시합니다."
                      defaultChecked
                    />
                    <PolicyRow
                      icon={CreditCard}
                      title="카드 지연 승인 감시"
                      description="카드 승인 데이터가 2시간 이상 지연되면 운영 경고를 띄웁니다."
                      defaultChecked={false}
                    />
                  </CardContent>
                </Card>

                <Card className="rounded-3xl border-border/70 shadow-sm">
                  <CardHeader>
                    <CardDescription>Admin Broadcast</CardDescription>
                    <CardTitle className="text-xl">운영자 공지 초안</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <Input defaultValue="미래에셋 권한 재승인 안내" />
                    <Textarea
                      className="min-h-40"
                      defaultValue="일부 투자 연동 사용자의 권한이 만료되어 재승인이 필요합니다. 앱 설정 > 연동 인증 관리에서 다시 승인해 주세요."
                    />
                    <div className="flex gap-2">
                      <Button className="rounded-full">공지 저장</Button>
                      <Button variant="outline" className="rounded-full">미리보기</Button>
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>
            </Tabs>
          </div>
        </div>
      </SidebarInset>
    </SidebarProvider>
  )
}

function MetricCard({
  title,
  value,
  description,
  icon: Icon,
  tone,
}: {
  title: string
  value: string
  description: string
  icon: React.ComponentType<{ className?: string }>
  tone: "sky" | "emerald" | "amber" | "rose"
}) {
  const toneMap = {
    sky: "from-sky-500/15 to-sky-500/5 text-sky-700 dark:text-sky-300",
    emerald: "from-emerald-500/15 to-emerald-500/5 text-emerald-700 dark:text-emerald-300",
    amber: "from-amber-500/15 to-amber-500/5 text-amber-700 dark:text-amber-300",
    rose: "from-rose-500/15 to-rose-500/5 text-rose-700 dark:text-rose-300",
  }

  return (
    <Card className={`rounded-3xl border-border/70 bg-gradient-to-br ${toneMap[tone]} shadow-sm`}>
      <CardContent className="flex items-start justify-between gap-4 p-6">
        <div className="space-y-2">
          <p className="text-sm font-medium text-muted-foreground">{title}</p>
          <p className="text-3xl font-semibold tracking-tight text-foreground">{value}</p>
          <p className="text-sm text-muted-foreground">{description}</p>
        </div>
        <div className="flex size-12 items-center justify-center rounded-2xl bg-background/90 shadow-sm">
          <Icon className="size-5 text-foreground" />
        </div>
      </CardContent>
    </Card>
  )
}

function SnapshotStat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-2xl border border-border/60 bg-muted/20 p-4">
      <p className="text-xs font-medium uppercase tracking-[0.16em] text-muted-foreground">{label}</p>
      <p className="mt-2 text-sm font-semibold text-foreground">{value}</p>
    </div>
  )
}

function StatusBadge({ status }: { status: "active" | "pending" | "risk" }) {
  const config = {
    active: "bg-emerald-500/10 text-emerald-700 dark:text-emerald-300",
    pending: "bg-amber-500/10 text-amber-700 dark:text-amber-300",
    risk: "bg-rose-500/10 text-rose-700 dark:text-rose-300",
  }

  const label = {
    active: "정상",
    pending: "승인대기",
    risk: "위험",
  }

  return <Badge className={`rounded-full border-0 ${config[status]}`}>{label[status]}</Badge>
}

function ProviderBadge({
  status,
}: {
  status: "connected" | "pendingConsent" | "permissionRequired" | "error"
}) {
  const label = {
    connected: "연동 완료",
    pendingConsent: "동의 대기",
    permissionRequired: "권한 필요",
    error: "오류",
  }

  const className = {
    connected: "bg-emerald-500/10 text-emerald-700 dark:text-emerald-300",
    pendingConsent: "bg-sky-500/10 text-sky-700 dark:text-sky-300",
    permissionRequired: "bg-amber-500/10 text-amber-700 dark:text-amber-300",
    error: "bg-rose-500/10 text-rose-700 dark:text-rose-300",
  }

  return <Badge className={`rounded-full border-0 ${className[status]}`}>{label[status]}</Badge>
}

function PolicyRow({
  icon: Icon,
  title,
  description,
  defaultChecked,
}: {
  icon: React.ComponentType<{ className?: string }>
  title: string
  description: string
  defaultChecked: boolean
}) {
  return (
    <div className="flex items-center justify-between gap-4 rounded-2xl border border-border/60 bg-muted/20 p-4">
      <div className="flex items-start gap-3">
        <div className="mt-0.5 flex size-10 items-center justify-center rounded-2xl bg-background shadow-sm">
          <Icon className="size-4 text-primary" />
        </div>
        <div>
          <p className="font-medium">{title}</p>
          <p className="mt-1 text-sm leading-6 text-muted-foreground">{description}</p>
        </div>
      </div>
      <Switch defaultChecked={defaultChecked} />
    </div>
  )
}

function currency(value: number) {
  return new Intl.NumberFormat("ko-KR", {
    style: "currency",
    currency: "KRW",
    maximumFractionDigits: 0,
  }).format(value)
}
