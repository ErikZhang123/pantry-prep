# PantryPrep — Project Context for Claude Code

## Project Overview

An iPhone app that converts recipe names into ingredient checklists and shopping lists, powered by an AI backend.

**Core user flow:**
1. User enters recipe names → selects servings → taps Generate
2. App calls Python backend → backend calls Claude API → returns structured ingredients
3. App normalizes and merges ingredients locally
4. User checks off ingredients they already have
5. Unchecked ingredients form the shopping list
6. State is saved locally; survives app restart

---

## Stack Decisions (Confirmed)

### iOS App
- Language: Swift
- UI: SwiftUI (no UIKit)
- State/Persistence: SwiftData + AppStorage
- Networking: URLSession + Codable
- Architecture: MVVM
- Target: iPhone portrait-first
- App name: **PantryPrep**

### Python Backend
- Language: Python 3.11+
- Framework: FastAPI
- Package manager: uv
- AI: Anthropic Claude API — model `claude-haiku-4-5-20251001`
- Server: uvicorn
- Config: python-dotenv

### Infrastructure
- Local development now
- Future deployment: AWS (target undecided — EC2 / Lambda / ECS are all candidates)
- No secrets hardcoded; base URL configurable in iOS app

---

## Development Environment

| Machine | Role |
|---------|------|
| Windows 11 (current) | Python backend development |
| Mac (available) | iOS Xcode/SwiftUI development |

Sync between machines via **Git + GitHub**.

### Tools installed on Windows
- Python 3.11+
- VS Code + Python + Pylance extensions
- Git
- Postman
- uv

### Tools needed on Mac (when switching)
- Xcode 16+ (Mac App Store)
- Git (via `xcode-select --install`)
- VS Code (optional)
- Claude Code CLI: `npm install -g @anthropic-ai/claude-code`

---

## Backend Architecture

### Endpoint
```
POST /generate-ingredients
```

**Request:**
```json
{
  "recipes": ["Tomato Scrambled Eggs", "Miso Soup"],
  "servings": 2,
  "includePantryStaples": false
}
```

**Response:**
```json
{
  "ingredients": [
    {
      "id": "1",
      "displayName": "Eggs",
      "canonicalName": "egg",
      "quantity": 4,
      "unit": "pcs",
      "category": "protein",
      "optional": false,
      "pantryStaple": false,
      "recipeName": "Tomato Scrambled Eggs"
    }
  ]
}
```

### Backend responsibilities
- Receive recipe names + servings + pantry preference
- Build a structured prompt for Claude
- Call Claude API (haiku) with the prompt
- Parse Claude's response into the ingredient DTO schema
- Return clean JSON to the iOS app
- Handle Claude API errors gracefully

### Backend project structure (planned)
```
backend/
├── main.py               # FastAPI app entry point
├── routers/
│   └── ingredients.py    # POST /generate-ingredients
├── services/
│   └── claude_service.py # Claude API call + prompt logic
├── models/
│   └── schemas.py        # Pydantic request/response models
├── prompts/
│   └── ingredient_prompt.py  # Prompt templates
├── .env                  # ANTHROPIC_API_KEY (never commit)
├── .env.example          # Safe to commit
├── requirements.txt      # or pyproject.toml
└── README.md
```

---

## iOS Architecture

### Folder structure
```
PantryPrep/
├── App/
│   ├── PantryPrepApp.swift
│   └── AppConfig.swift         # base URL, mock toggle
├── Models/
│   ├── IngredientDTO.swift      # API response shape
│   ├── MergedIngredient.swift   # local merged model
│   └── IngredientSource.swift   # per-recipe source info
├── Views/
│   ├── HomeView.swift
│   ├── IngredientChecklistView.swift
│   ├── IngredientRowView.swift
│   ├── EditIngredientSheet.swift
│   ├── ShoppingListView.swift
│   └── SettingsView.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── IngredientChecklistViewModel.swift
│   ├── ShoppingListViewModel.swift
│   └── SettingsViewModel.swift
├── Services/
│   ├── IngredientAPIService.swift
│   ├── MockIngredientService.swift
│   └── IngredientGenerationService.swift  # facade, switches mock/live
├── Persistence/
│   └── PersistenceController.swift
├── Utilities/
│   ├── IngredientNormalizer.swift
│   ├── IngredientMerger.swift
│   └── ShareFormatter.swift
└── PantryPrepTests/
    ├── NormalizerTests.swift
    ├── MergerTests.swift
    ├── ShoppingListBuilderTests.swift
    └── ShareFormatterTests.swift
```

### Data flow
```
View → ViewModel → IngredientGenerationService
                         ↓ (mock or live)
                   MockService / APIService
                         ↓
                   IngredientNormalizer
                         ↓
                   IngredientMerger
                         ↓
                   MergedIngredient[]  ←→  SwiftData
                         ↓
                   ShoppingListBuilder (filter owned == false)
```

---

## Core Logic Rules

### Normalization
- Lowercase + trim all canonical names
- Singularize safe plurals: `eggs → egg`, `tomatoes → tomato`
- Apply synonym map: `spring onion → green onion`, `scallions → green onion`
- `canonicalName` is the merge key

### Merge rules
| Case | Behavior |
|------|----------|
| Same unit | Sum quantities, preserve sources |
| One/both quantity missing | Keep quantity nullable, preserve sources |
| Different units | Do NOT convert; set `needsReview = true`, show UI warning |

### Shopping list
- Derived view: `ingredients.filter { !$0.owned }`
- Updates reactively when user toggles owned
- Pantry staples excluded if user setting is off

---

## Ingredient Categories
`vegetable`, `protein`, `dairy`, `condiment`, `grain`, `spice`, `pantry`, `seafood`, `fruit`, `other`

---

## Screens

| Screen | Key elements |
|--------|-------------|
| **Home** | Recipe text input, servings stepper, pantry staples toggle, Generate button, quick-fill example chips, loading/error states |
| **Ingredient Checklist** | Grouped by category, owned toggle per row, edit sheet, swipe-to-delete, needsReview badge, toolbar: reset / regenerate / continue |
| **Shopping List** | Grouped by category, empty state, copy to clipboard, share sheet |
| **Settings** | Default servings, pantry staples default, save history toggle, clear data button |

---

## Mock Mode

- `MockIngredientService` returns realistic hardcoded ingredient data
- `AppConfig.swift` has a single `useMock: Bool` flag
- All SwiftUI Previews use mock mode
- Live mode activated by setting base URL + flipping mock flag

---

## Persistence

| Data | Storage |
|------|---------|
| Current ingredient list + owned states | SwiftData |
| Last entered recipes + servings | SwiftData |
| Default servings preference | AppStorage |
| Include pantry staples preference | AppStorage |
| Save history on/off | AppStorage |

App restores last working session on relaunch.

---

## Implementation Order

| Phase | Work | Machine | Status |
|-------|------|---------|--------|
| 1 | Python backend: FastAPI setup + `/generate-ingredients` + Claude prompt | Windows | ✅ Done |
| 2 | Backend: Pydantic models + error handling + local test via Postman | Windows | ✅ Done |
| 3 | iOS: Xcode project setup + navigation structure + placeholder screens | Mac | ⬜ Next |
| 4 | iOS: Models + Mock service + basic checklist render | Mac | ⬜ |
| 5 | iOS: Normalizer + Merger + unit tests | Mac | ⬜ |
| 6 | iOS: Checklist UX (toggle, edit sheet, delete, grouped sections) | Mac | ⬜ |
| 7 | iOS: Persistence (SwiftData + AppStorage) | Mac | ⬜ |
| 8 | iOS: Live API networking + mock/live switch | Mac | ⬜ |
| 9 | iOS: Shopping list screen + share/copy | Mac | ⬜ |
| 10 | iOS + Backend: Polish, edge cases, README | Both | ⬜ |

---

## Edge Cases to Handle

- Empty recipe input
- Duplicate recipe names in input
- Network timeout / failure
- Invalid / malformed Claude response
- Ingredient with missing quantity or unit
- Same ingredient from two recipes with conflicting units
- All items checked (empty shopping list state)
- All items filtered out by pantry staple setting

App must never crash from any of these.

---

## AWS Deployment (Future — Not Started)

Planned approach:
- Containerize backend with Docker
- Deploy to AWS (ECS Fargate or Lambda — TBD based on traffic pattern)
- Use AWS Secrets Manager for `ANTHROPIC_API_KEY`
- iOS app base URL switches from `localhost` to deployed domain
- Consider API Gateway if using Lambda

---

## Mac 上手指南（切换到 Mac 后从这里开始）

### 当前进度
Phase 1 & 2 已在 Windows 上完成：
- 后端代码在 `backend/` 目录，FastAPI + Claude Haiku，完整可运行
- GitHub 仓库：`https://github.com/ErikZhang123/pantry-prep`
- 后端 API 已测试通过，`POST /generate-ingredients` 返回正确 JSON

### Mac 第一步：拉取代码
```bash
git clone https://github.com/ErikZhang123/pantry-prep.git
cd pantry-prep
```

### Mac 第二步：开始 Phase 3
**目标：** 在 Xcode 创建 iOS 项目，搭建导航结构和占位屏幕。

具体任务：
1. 打开 Xcode → New Project → App，命名 `PantryPrep`，Bundle ID 自定，Language: Swift，Interface: SwiftUI，勾选 SwiftData
2. 删除默认的 `ContentView.swift`，按 iOS 架构章节的目录结构创建文件夹和占位文件
3. 实现 `TabView` 或 `NavigationStack` 串联 HomeView / IngredientChecklistView / ShoppingListView / SettingsView（占位即可，有文字能跳转就行）
4. 创建 `AppConfig.swift`，包含 `baseURL` 和 `useMock: Bool = true`
5. 确认 Preview 能跑通

### 后端本地启动方式（Mac 上测试联调时用）
```bash
cd pantry-prep/backend
python -m uv sync
echo "ANTHROPIC_API_KEY=你的密钥" > .env
python -m uv run uvicorn main:app --reload --port 8000
```

---

## Key Engineering Rules

- Business logic (normalizer, merger, shopping list builder) must be pure functions, fully unit-tested
- Views contain zero business logic
- Mock-first: every feature works in mock mode before live API is connected
- No hardcoded secrets anywhere in the codebase
- No TODO placeholders left in core features at delivery
- Prefer readable Swift over clever abstractions
