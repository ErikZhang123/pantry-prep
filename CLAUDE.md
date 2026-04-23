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

| Phase | Work | Machine |
|-------|------|---------|
| 1 | Python backend: FastAPI setup + `/generate-ingredients` + Claude prompt | Windows |
| 2 | Backend: Pydantic models + error handling + local test via Postman | Windows |
| 3 | iOS: Xcode project setup + navigation structure + placeholder screens | Mac |
| 4 | iOS: Models + Mock service + basic checklist render | Mac |
| 5 | iOS: Normalizer + Merger + unit tests | Mac |
| 6 | iOS: Checklist UX (toggle, edit sheet, delete, grouped sections) | Mac |
| 7 | iOS: Persistence (SwiftData + AppStorage) | Mac |
| 8 | iOS: Live API networking + mock/live switch | Mac |
| 9 | iOS: Shopping list screen + share/copy | Mac |
| 10 | iOS + Backend: Polish, edge cases, README | Both |

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

## Key Engineering Rules

- Business logic (normalizer, merger, shopping list builder) must be pure functions, fully unit-tested
- Views contain zero business logic
- Mock-first: every feature works in mock mode before live API is connected
- No hardcoded secrets anywhere in the codebase
- No TODO placeholders left in core features at delivery
- Prefer readable Swift over clever abstractions
