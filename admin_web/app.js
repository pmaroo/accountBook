const STORAGE_KEY = "ftw-admin-portal-state";

const statusLabels = {
  disconnected: "연결 안 됨",
  authorizationRequired: "인증 필요",
  pendingConsent: "본인 확인 대기",
  permissionRequired: "권한 필요",
  connected: "연동 완료",
  error: "오류",
};

const statusClasses = {
  disconnected: "alert",
  authorizationRequired: "warning",
  pendingConsent: "warning",
  permissionRequired: "warning",
  connected: "connected",
  error: "alert",
};

const typeLabels = {
  income: "수입",
  expense: "지출",
  transfer: "이체",
};

const providerTypeLabels = {
  bank: "은행",
  card: "카드",
  investment: "투자",
  payment: "결제",
};

const appState = {
  data: loadState(),
  section: "dashboard",
};

init();

function init() {
  bindGlobalEvents();
  render();
}

function bindGlobalEvents() {
  document.querySelectorAll(".nav-link").forEach((button) => {
    button.addEventListener("click", () => {
      appState.section = button.dataset.section;
      renderSections();
    });
  });

  document
    .getElementById("export-backup-button")
    .addEventListener("click", exportBackupJson);

  document
    .getElementById("reset-demo-button")
    .addEventListener("click", () => {
      appState.data = createSampleState();
      saveState();
      render();
    });

  document
    .getElementById("backup-file-input")
    .addEventListener("change", handleBackupImport);

  document
    .getElementById("add-category-button")
    .addEventListener("click", addCategory);

  document.getElementById("add-goal-button").addEventListener("click", addGoal);

  document
    .getElementById("transaction-search")
    .addEventListener("input", renderTransactions);

  document
    .getElementById("transaction-type-filter")
    .addEventListener("change", renderTransactions);
}

function render() {
  renderSections();
  renderSummary();
  renderHeatmap();
  renderProviderHealth();
  renderCategories();
  renderGoals();
  renderProviders();
  renderTransactions();
  renderSettings();
  renderStorageStatus();
}

function renderSections() {
  document.querySelectorAll(".nav-link").forEach((button) => {
    button.classList.toggle("active", button.dataset.section === appState.section);
  });

  document.querySelectorAll(".section").forEach((section) => {
    section.classList.toggle("active", section.id === appState.section);
  });
}

function renderSummary() {
  const root = document.getElementById("summary-grid");
  const totalBudget = appState.data.categories.reduce(
    (sum, item) => sum + item.monthlyBudget,
    0,
  );
  const totalGoals = appState.data.goals.reduce(
    (sum, item) => sum + item.targetAmount,
    0,
  );
  const transactionCount = appState.data.transactions.length;
  const connectedProviders = appState.data.syncProviders.filter(
    (item) => item.authStatus === "connected",
  ).length;

  root.innerHTML = [
    summaryCard("월 예산 총합", formatWon(totalBudget), "카테고리 예산 기준"),
    summaryCard("목표 총액", formatWon(totalGoals), "저축 목표 누적 기준"),
    summaryCard("거래 건수", `${transactionCount}건`, "백업 데이터 포함"),
    summaryCard("정상 연동", `${connectedProviders}개`, "연동 완료 공급자"),
  ].join("");
}

function summaryCard(label, value, hint) {
  return `
    <article class="summary-card">
      <p class="eyebrow">${label}</p>
      <strong>${value}</strong>
      <p>${hint}</p>
    </article>
  `;
}

function renderHeatmap() {
  const root = document.getElementById("budget-heatmap");
  const expenseMap = buildExpenseMap();
  const items = appState.data.categories
    .map((category) => {
      const used = expenseMap.get(category.id) ?? 0;
      const rate = category.monthlyBudget === 0 ? 0 : Math.round((used / category.monthlyBudget) * 100);
      return { category, used, rate };
    })
    .sort((a, b) => b.rate - a.rate);

  root.innerHTML = items
    .map(
      ({ category, used, rate }) => `
        <div class="stack-item">
          <div class="stack-row">
            <strong>${category.name}</strong>
            <span>${rate}%</span>
          </div>
          <div class="hint">${formatWon(used)} / ${formatWon(category.monthlyBudget)}</div>
          <div class="budget-bar"><span style="width:${Math.min(rate, 100)}%"></span></div>
        </div>
      `,
    )
    .join("");
}

function renderProviderHealth() {
  const root = document.getElementById("provider-health");
  root.innerHTML = appState.data.syncProviders
    .map(
      (provider) => `
        <div class="stack-item">
          <div class="stack-row">
            <strong>${provider.name}</strong>
            <span class="pill ${statusClasses[provider.authStatus]}">${statusLabels[provider.authStatus]}</span>
          </div>
          <div class="hint">${provider.statusMessage || "상태 메시지 없음"}</div>
        </div>
      `,
    )
    .join("");
}

function renderCategories() {
  const rows = appState.data.categories.map((category, index) => ({
    name: editableText(category.name, (value) => updateCategory(index, "name", value)),
    monthlyBudget: editableNumber(
      category.monthlyBudget,
      (value) => updateCategory(index, "monthlyBudget", value),
    ),
    isFixed: editableToggle(category.isFixed, (value) => updateCategory(index, "isFixed", value)),
    actions: `
      <div class="action-row">
        <button class="tiny-button danger" onclick="removeCategory(${index})">삭제</button>
      </div>
    `,
  }));

  renderTable(document.getElementById("categories-table"), ["카테고리명", "월 예산", "고정 항목", "관리"], rows);
}

function renderGoals() {
  const rows = appState.data.goals.map((goal, index) => ({
    title: editableText(goal.title, (value) => updateGoal(index, "title", value)),
    targetAmount: editableNumber(goal.targetAmount, (value) => updateGoal(index, "targetAmount", value)),
    currentAmount: editableNumber(goal.currentAmount, (value) => updateGoal(index, "currentAmount", value)),
    progress: `${Math.min(Math.round((goal.currentAmount / Math.max(goal.targetAmount, 1)) * 100), 999)}%`,
    actions: `
      <div class="action-row">
        <button class="tiny-button danger" onclick="removeGoal(${index})">삭제</button>
      </div>
    `,
  }));

  renderTable(
    document.getElementById("goals-table"),
    ["목표명", "목표 금액", "현재 금액", "진행률", "관리"],
    rows,
  );
}

function renderProviders() {
  const root = document.getElementById("providers-grid");
  root.innerHTML = appState.data.syncProviders
    .map(
      (provider, index) => `
        <article class="provider-card">
          <div class="provider-top">
            <div>
              <p class="eyebrow">${providerTypeLabels[provider.type] || provider.type}</p>
              <h4>${provider.name}</h4>
            </div>
            <span class="pill ${statusClasses[provider.authStatus]}">${statusLabels[provider.authStatus]}</span>
          </div>
          <p class="hint">${provider.statusMessage || "운영 메모 없음"}</p>
          <div class="provider-meta">
            <span>권한: ${provider.hasPermission ? "승인" : "미승인"}</span>
            <span>연결: ${provider.isConnected ? "활성" : "비활성"}</span>
          </div>
          <div class="provider-meta">
            <span>최근 인증: ${formatDate(provider.lastAuthorizedAt)}</span>
            <span>최근 동기화: ${formatDate(provider.lastSyncedAt)}</span>
          </div>
          <div class="action-row" style="margin-top:14px;">
            ${providerStatusSelector(index, provider.authStatus)}
            ${inlineProviderToggle(index, "isConnected", provider.isConnected, "앱 연결")}
            ${inlineProviderToggle(index, "hasPermission", provider.hasPermission, "권한 허용")}
          </div>
          <div class="action-row" style="margin-top:10px;">
            <button class="tiny-button" onclick="markAuthorized(${index})">인증 완료 처리</button>
            <button class="tiny-button danger" onclick="markProviderError(${index})">오류 처리</button>
          </div>
        </article>
      `,
    )
    .join("");
}

function renderTransactions() {
  const query = document.getElementById("transaction-search").value.trim().toLowerCase();
  const filter = document.getElementById("transaction-type-filter").value;
  const rows = appState.data.transactions
    .filter((item) => {
      const matchQuery =
        query.length === 0 ||
        item.title.toLowerCase().includes(query) ||
        item.sourceName.toLowerCase().includes(query);
      const matchFilter = filter === "all" || item.type === filter;
      return matchQuery && matchFilter;
    })
    .sort((a, b) => new Date(b.date) - new Date(a.date))
    .map((item) => ({
      title: `<strong>${escapeHtml(item.title)}</strong><div class="hint">${escapeHtml(item.sourceName)}</div>`,
      amount: formatWon(item.amount),
      type: typeLabels[item.type] || item.type,
      categoryId: escapeHtml(item.categoryId),
      date: formatDate(item.date),
      source: item.isAutoSynced ? "자동 연동" : "수동 입력",
    }));

  renderTable(
    document.getElementById("transactions-table"),
    ["제목", "금액", "유형", "카테고리", "거래일", "입력 방식"],
    rows,
  );
}

function renderSettings() {
  const form = document.getElementById("settings-form");
  const settings = appState.data.settings;
  form.innerHTML = `
    <div class="setting-card">
      <div class="setting-row">
        <div>
          <strong>자동 내역 동기화</strong>
          <p class="hint">연결된 서비스의 새 데이터를 반영합니다.</p>
        </div>
        <input class="inline-toggle" type="checkbox" ${settings.autoSyncEnabled ? "checked" : ""} onchange="updateSetting('autoSyncEnabled', this.checked)" />
      </div>
    </div>
    <div class="setting-card">
      <div class="setting-row">
        <div>
          <strong>절약 플랜 추천</strong>
          <p class="hint">소비 패턴 기반 제안을 홈과 통계에서 노출합니다.</p>
        </div>
        <input class="inline-toggle" type="checkbox" ${settings.savingsTipsEnabled ? "checked" : ""} onchange="updateSetting('savingsTipsEnabled', this.checked)" />
      </div>
    </div>
    <div class="setting-card">
      <div class="setting-row">
        <div>
          <strong>챌린지 리마인더</strong>
          <p class="hint">하루 소비 목표를 초과하기 전에 알림을 보냅니다.</p>
        </div>
        <input class="inline-toggle" type="checkbox" ${settings.challengeReminderEnabled ? "checked" : ""} onchange="updateSetting('challengeReminderEnabled', this.checked)" />
      </div>
    </div>
    <div class="setting-card">
      <div class="setting-row">
        <div>
          <strong>챌린지 하루 목표 금액</strong>
          <p class="hint">사용자에게 권장할 하루 사용 한도입니다.</p>
        </div>
        <input type="number" value="${settings.challengeDailyTarget}" onchange="updateSetting('challengeDailyTarget', Number(this.value || 0))" />
      </div>
    </div>
  `;
}

function renderStorageStatus() {
  document.getElementById("storage-badge").textContent = "브라우저 로컬 저장 + 백업 JSON 호환";
  document.getElementById("last-saved-label").textContent = `마지막 저장 ${new Date().toLocaleString("ko-KR")}`;
}

function renderTable(root, headers, rows) {
  const template = document.getElementById("table-template");
  const table = template.content.firstElementChild.cloneNode(true);
  const thead = table.querySelector("thead");
  const tbody = table.querySelector("tbody");

  thead.innerHTML = `<tr>${headers.map((item) => `<th>${item}</th>`).join("")}</tr>`;
  tbody.innerHTML = rows
    .map((row) => `<tr>${Object.values(row).map((value) => `<td>${value}</td>`).join("")}</tr>`)
    .join("");
  root.innerHTML = "";
  root.appendChild(table);
}

function editableText(value, onChange) {
  const id = registerAction(onChange);
  return `<input class="inline-input" value="${escapeHtml(value)}" onchange="runAction('${id}', this.value)" />`;
}

function editableNumber(value, onChange) {
  const id = registerAction((next) => onChange(Number(next || 0)));
  return `<input class="inline-input" type="number" value="${value}" onchange="runAction('${id}', this.value)" />`;
}

function editableToggle(value, onChange) {
  const id = registerAction((next) => onChange(next));
  return `<input class="inline-toggle" type="checkbox" ${value ? "checked" : ""} onchange="runAction('${id}', this.checked)" />`;
}

function providerStatusSelector(index, selected) {
  return `
    <select class="inline-select" onchange="updateProvider(${index}, 'authStatus', this.value)">
      ${Object.keys(statusLabels)
        .map(
          (status) =>
            `<option value="${status}" ${status === selected ? "selected" : ""}>${statusLabels[status]}</option>`,
        )
        .join("")}
    </select>
  `;
}

function inlineProviderToggle(index, field, checked, label) {
  return `
    <label class="tiny-button">
      <input type="checkbox" ${checked ? "checked" : ""} onchange="updateProvider(${index}, '${field}', this.checked)" />
      ${label}
    </label>
  `;
}

const actionRegistry = new Map();

function registerAction(handler) {
  const id = `action-${crypto.randomUUID()}`;
  actionRegistry.set(id, handler);
  return id;
}

window.runAction = function runAction(id, value) {
  const handler = actionRegistry.get(id);
  if (!handler) {
    return;
  }
  handler(value);
  saveState();
  render();
};

window.updateCategory = function updateCategory(index, field, value) {
  appState.data.categories[index][field] = value;
  saveState();
  render();
};

window.removeCategory = function removeCategory(index) {
  const category = appState.data.categories[index];
  const inUse = appState.data.transactions.some((item) => item.categoryId === category.id);
  if (inUse) {
    alert("이 카테고리는 거래에서 사용 중이라 관리자에서 바로 삭제할 수 없습니다.");
    return;
  }
  appState.data.categories.splice(index, 1);
  saveState();
  render();
};

window.updateGoal = function updateGoal(index, field, value) {
  appState.data.goals[index][field] = value;
  saveState();
  render();
};

window.removeGoal = function removeGoal(index) {
  appState.data.goals.splice(index, 1);
  saveState();
  render();
};

window.updateProvider = function updateProvider(index, field, value) {
  appState.data.syncProviders[index][field] = value;
  saveState();
  render();
};

window.markAuthorized = function markAuthorized(index) {
  const provider = appState.data.syncProviders[index];
  provider.authStatus = "connected";
  provider.hasPermission = true;
  provider.isConnected = true;
  provider.lastAuthorizedAt = new Date().toISOString();
  provider.statusMessage = "관리자 포털에서 인증 완료 처리되었습니다.";
  saveState();
  render();
};

window.markProviderError = function markProviderError(index) {
  const provider = appState.data.syncProviders[index];
  provider.authStatus = "error";
  provider.statusMessage = "운영자가 수동 점검이 필요하다고 표시했습니다.";
  saveState();
  render();
};

window.updateSetting = function updateSetting(field, value) {
  appState.data.settings[field] = value;
  saveState();
  render();
};

function addCategory() {
  appState.data.categories.unshift({
    id: `category-${Date.now()}`,
    name: "새 카테고리",
    monthlyBudget: 0,
    isFixed: false,
    colorValue: 4283190343,
    iconCodePoint: 58728,
  });
  saveState();
  render();
}

function addGoal() {
  appState.data.goals.unshift({
    id: `goal-${Date.now()}`,
    title: "새 목표",
    targetAmount: 1000000,
    currentAmount: 0,
  });
  saveState();
  render();
}

function exportBackupJson() {
  const blob = new Blob([JSON.stringify(appState.data, null, 2)], {
    type: "application/json",
  });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = `admin_backup_${new Date().toISOString().replaceAll(":", "-")}.json`;
  anchor.click();
  URL.revokeObjectURL(url);
}

function handleBackupImport(event) {
  const file = event.target.files?.[0];
  if (!file) {
    return;
  }

  const reader = new FileReader();
  reader.onload = () => {
    try {
      const parsed = JSON.parse(String(reader.result));
      appState.data = normalizeState(parsed);
      saveState();
      render();
      alert("백업 JSON을 관리자 포털에 불러왔습니다.");
    } catch (error) {
      alert("백업 JSON 형식을 읽지 못했습니다.");
    }
  };
  reader.readAsText(file, "utf-8");
  event.target.value = "";
}

function buildExpenseMap() {
  const map = new Map();
  appState.data.transactions
    .filter((item) => item.type === "expense")
    .forEach((item) => {
      map.set(item.categoryId, (map.get(item.categoryId) || 0) + item.amount);
    });
  return map;
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(appState.data));
}

function loadState() {
  const saved = localStorage.getItem(STORAGE_KEY);
  if (!saved) {
    return createSampleState();
  }

  try {
    return normalizeState(JSON.parse(saved));
  } catch (error) {
    return createSampleState();
  }
}

function normalizeState(raw) {
  return {
    categories: Array.isArray(raw.categories) ? raw.categories : [],
    transactions: Array.isArray(raw.transactions) ? raw.transactions : [],
    accounts: Array.isArray(raw.accounts) ? raw.accounts : [],
    goals: Array.isArray(raw.goals) ? raw.goals : [],
    syncProviders: Array.isArray(raw.syncProviders) ? raw.syncProviders : [],
    settings: {
      autoSyncEnabled: Boolean(raw.settings?.autoSyncEnabled),
      savingsTipsEnabled: Boolean(raw.settings?.savingsTipsEnabled),
      challengeReminderEnabled: Boolean(raw.settings?.challengeReminderEnabled),
      challengeDailyTarget: Number(raw.settings?.challengeDailyTarget || 0),
    },
  };
}

function formatWon(value) {
  return `${Number(value || 0).toLocaleString("ko-KR")}원`;
}

function formatDate(value) {
  if (!value) {
    return "없음";
  }
  return new Date(value).toLocaleDateString("ko-KR");
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function createSampleState() {
  const now = new Date();
  const yyyy = now.getFullYear();
  const mm = now.getMonth() + 1;
  return {
    categories: [
      { id: "food", name: "식비", monthlyBudget: 300000, isFixed: false, colorValue: 4293359441, iconCodePoint: 58260 },
      { id: "rent", name: "월세", monthlyBudget: 650000, isFixed: true, colorValue: 4281682000, iconCodePoint: 58719 },
      { id: "living", name: "생활비", monthlyBudget: 220000, isFixed: false, colorValue: 4283916432, iconCodePoint: 58407 },
      { id: "travel", name: "여행저축", monthlyBudget: 180000, isFixed: true, colorValue: 4280981135, iconCodePoint: 58217 },
      { id: "emergency", name: "비상금", monthlyBudget: 150000, isFixed: true, colorValue: 4280706147, iconCodePoint: 57530 },
    ],
    transactions: [
      {
        id: "seed-1",
        title: "월급",
        amount: 2800000,
        type: "income",
        categoryId: "income",
        date: new Date(yyyy, mm - 1, 25).toISOString(),
        sourceName: "회사 급여계좌",
        isAutoSynced: true,
        providerId: "salary",
        externalId: `salary-${mm}`,
      },
      {
        id: "seed-2",
        title: "월세 이체",
        amount: 650000,
        type: "expense",
        categoryId: "rent",
        date: new Date(yyyy, mm - 1, 1).toISOString(),
        sourceName: "토스뱅크",
        isAutoSynced: true,
        providerId: "toss_bank",
        externalId: `rent-${mm}`,
      },
      {
        id: "seed-3",
        title: "장보기",
        amount: 126000,
        type: "expense",
        categoryId: "food",
        date: new Date(yyyy, mm - 1, Math.max(now.getDate() - 1, 1)).toISOString(),
        sourceName: "현대카드",
        isAutoSynced: true,
        providerId: "hyundai_card",
        externalId: `food-${now.getDate()}`,
      },
      {
        id: "seed-4",
        title: "생활용품 구매",
        amount: 82000,
        type: "expense",
        categoryId: "living",
        date: new Date(yyyy, mm - 1, Math.max(now.getDate() - 3, 1)).toISOString(),
        sourceName: "쿠팡",
        isAutoSynced: false,
        providerId: null,
        externalId: null,
      },
    ],
    accounts: [
      { id: "a1", name: "토스뱅크 자유적금", kind: "bank", principal: 2200000, currentBalance: 2279000, isLinked: true, providerId: "toss_bank" },
      { id: "a2", name: "미래에셋 ISA", kind: "securities", principal: 1800000, currentBalance: 1968000, isLinked: true, providerId: "mirae_asset" },
    ],
    goals: [
      { id: "g1", title: "비상금 300만원", targetAmount: 3000000, currentAmount: 1280000 },
      { id: "g2", title: "여행저축 200만원", targetAmount: 2000000, currentAmount: 920000 },
    ],
    syncProviders: [
      {
        id: "toss_bank",
        name: "토스뱅크",
        type: "bank",
        isConnected: true,
        hasPermission: true,
        authStatus: "connected",
        lastSyncedAt: new Date(yyyy, mm - 1, Math.max(now.getDate() - 1, 1)).toISOString(),
        statusMessage: "계좌 잔액과 거래내역 동기화 준비 완료",
        lastAuthorizedAt: new Date(yyyy, mm - 1, Math.max(now.getDate() - 4, 1)).toISOString(),
      },
      {
        id: "hyundai_card",
        name: "현대카드",
        type: "card",
        isConnected: true,
        hasPermission: true,
        authStatus: "connected",
        lastSyncedAt: new Date(yyyy, mm - 1, Math.max(now.getDate() - 2, 1)).toISOString(),
        statusMessage: "카드 승인내역 자동 연동 중",
        lastAuthorizedAt: new Date(yyyy, mm - 1, Math.max(now.getDate() - 6, 1)).toISOString(),
      },
      {
        id: "mirae_asset",
        name: "미래에셋",
        type: "investment",
        isConnected: true,
        hasPermission: false,
        authStatus: "permissionRequired",
        lastSyncedAt: null,
        statusMessage: "평가금액 조회 권한이 아직 승인되지 않았습니다.",
        lastAuthorizedAt: new Date(yyyy, mm - 1, Math.max(now.getDate() - 8, 1)).toISOString(),
      },
    ],
    settings: {
      autoSyncEnabled: true,
      savingsTipsEnabled: true,
      challengeReminderEnabled: true,
      challengeDailyTarget: 10000,
    },
  };
}
