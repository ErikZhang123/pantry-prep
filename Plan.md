You are a senior iOS engineer and product-minded builder.

Your task is to build a demo-quality but real iPhone app using SwiftUI that helps users generate ingredient checklists and shopping lists from recipe names.

This is not a toy exercise. Build a polished, runnable iOS app MVP that can be opened in Xcode, run in simulator, and prepared for TestFlight later.

---

# PRODUCT GOAL

Build an iPhone app with this flow:

1. User enters one or more recipe names
2. User optionally selects servings
3. App sends recipe names to an AI-powered backend endpoint
4. Backend returns structured ingredient data
5. App normalizes and merges ingredients
6. User checks ingredients they already have
7. Unchecked ingredients automatically form a shopping list
8. App saves current state locally

This app should feel like a real product demo, not a mockup.

---

# MANDATORY STACK

Use:

- Swift
- SwiftUI
- SwiftData
- AppStorage where appropriate
- URLSession
- Codable
- MVVM-style structure or lightweight state store
- Xcode project targeting iPhone first

Do NOT use UIKit unless absolutely necessary.
Do NOT overengineer architecture.
Do NOT build Android support.
Focus on iPhone.

---

# APP NAME

Use a working title like:

- PantryPrep
or
- RecipeCart

Pick one and use it consistently throughout the project.

---

# CORE SCREENS

Build these screens:

## 1. Home / Recipe Input Screen
Purpose:
- User enters recipe names
- User selects servings
- User chooses whether to include pantry staples
- User taps generate

UI elements:
- App title
- Multi-line text field for recipe names (one per line)
- Stepper or picker for servings
- Toggle: Include pantry staples
- Primary button: Generate Ingredients
- Example recipe chips/buttons
- Error message area
- Loading indicator

---

## 2. Ingredient Checklist Screen
Purpose:
- Show merged ingredient checklist
- Allow user to mark owned ingredients
- Allow manual edits

UI elements:
- Grouped list by category
- Row for each ingredient:
  - Checkbox/toggle for owned
  - Ingredient name
  - Quantity + unit
  - Optional badge if needed
  - Pantry staple badge if needed
  - Edit button
  - Delete action
- Toolbar actions:
  - Reset checks
  - Regenerate
  - Continue to shopping list

---

## 3. Shopping List Screen
Purpose:
- Display ingredients not owned
- Group by category
- Allow sharing/copying

UI elements:
- Grouped shopping list
- Empty state if nothing to buy
- Copy/share button
- Optional plain text export preview

---

## 4. Settings Screen
Purpose:
- Store simple user preferences

Settings:
- Default servings
- Include pantry staples by default
- Save history on/off
- Clear local data button

Keep settings simple.

---

# DATA MODELS

Create clear Codable / SwiftData-compatible models.

## Remote DTO
Create an API DTO for AI result.

Example fields for ingredient DTO:
- id: String
- displayName: String
- canonicalName: String
- quantity: Double?
- unit: String?
- category: String
- optional: Bool
- pantryStaple: Bool
- recipeName: String

## Local Merged Model
Create a merged ingredient model used by UI and persistence.

Fields:
- id
- displayName
- canonicalName
- totalQuantity
- unit
- category
- optional
- pantryStaple
- owned
- sources
- needsReview (for unit conflicts)

If sources are modeled separately, make that clean and simple.

---

# REQUIRED CATEGORIES

Use these categories consistently:

- vegetable
- protein
- dairy
- condiment
- grain
- spice
- pantry
- seafood
- fruit
- other

You may display user-facing labels with better capitalization.

---

# NETWORK REQUIREMENT

The app must call a backend endpoint for ingredient generation.

Assume an endpoint like:

POST /generate-ingredients

Example request body:
{
  "recipes": ["Tomato Scrambled Eggs", "Miso Soup"],
  "servings": 2,
  "includePantryStaples": false
}

Example response body:
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

Implement a clean API client with:
- URLSession
- Codable decoding
- proper error handling
- timeout handling
- user-friendly error states

Do NOT hardcode secrets in the app.
Use a configurable base URL.
Use mock mode for local preview/demo if API is unavailable.

---

# OFFLINE / MOCK SUPPORT

This is very important.

Implement a mock generation mode so the app still works for demos without a live backend.

Requirements:
- A mock service that returns realistic sample ingredient data
- Easy switch between mock and live API
- Preview/testability without network dependency

Default to mock mode in previews.
Make live mode easy to enable in one place.

---

# NORMALIZATION LOGIC

Implement deterministic normalization locally on-device after receiving ingredients.

Rules:
1. lowercase canonical processing
2. trim whitespace
3. singularize simple plurals where safe
4. apply synonym mapping

Examples:
- tomatoes -> tomato
- eggs -> egg
- spring onion -> green onion
- scallions -> green onion

Use canonicalName as merge key.

Create a dedicated normalizer utility.

---

# MERGE RULES

Implement merge logic locally.

If ingredients share the same canonicalName:

## Case 1: Same unit
- Sum quantities if both are present
- Preserve sources

## Case 2: One or both quantities missing
- Keep quantity nullable if needed
- Preserve source entries

## Case 3: Different units
- Do NOT attempt unit conversion in MVP
- Mark item as needsReview = true
- Preserve source details
- Display a subtle UI warning

This logic must be deterministic and testable.

---

# CHECKLIST LOGIC

Checklist behavior:
- Each merged ingredient has owned = true/false
- User can toggle owned
- Shopping list is derived from ingredients where owned == false
- Pantry staples should be optionally excluded based on user setting

Implement reactive updates so shopping list changes immediately when checklist changes.

---

# LOCAL PERSISTENCE

Persist at least:
- current merged ingredient list
- owned states
- last entered recipes
- servings
- pantry staple preference

Use:
- SwiftData for current list/history if reasonable
- AppStorage for lightweight preferences

On app relaunch:
- restore last working state
- do not lose checklist progress

Also include a way to clear local data.

---

# ARCHITECTURE

Use a clean, simple structure.

Recommended folders / groups:

- App
- Models
- Views
- ViewModels
- Services
- Persistence
- Utilities

Suggested components:

## Services
- IngredientAPIService
- MockIngredientService
- IngredientGenerationService
- ShoppingListBuilder

## Utilities
- IngredientNormalizer
- IngredientMerger
- ShareFormatter

## ViewModels
- HomeViewModel
- IngredientChecklistViewModel
- ShoppingListViewModel
- SettingsViewModel

Do not build excessive abstraction layers.
Keep code understandable.

---

# UI / UX REQUIREMENTS

The app must look polished enough for a demo.

Requirements:
- modern SwiftUI styling
- clean spacing
- clear hierarchy
- pleasant typography
- empty states
- loading states
- error states
- swipe-to-delete where appropriate
- smooth navigation
- works on iPhone portrait first

Use NavigationStack.
Use List, Section, toolbar, sheet, confirmation dialogs where appropriate.

Include:
- example recipe quick-fill buttons
- helpful empty-state text
- non-ugly loading indicator
- subtle badges for pantry staple / optional / review needed

---

# EDITING SUPPORT

User must be able to manually fix AI output.

Implement edit flow:
- tap ingredient row or edit button
- open sheet/form
- edit:
  - display name
  - quantity
  - unit
  - category
  - pantry staple flag
- save changes back to list

Also support delete.

This is critical because AI output will not always be perfect.

---

# SHARE / EXPORT

Implement a simple export/share for shopping list.

Minimum:
- generate plain text shopping list grouped by category
- support copy to clipboard
- support share sheet

Example output:

Vegetable
- Tomato x2
- Green onion x1 bunch

Protein
- Egg x4

Keep formatting clean.

---

# TESTING REQUIREMENTS

Add unit tests at minimum for:
- normalization
- merge logic
- shopping list filtering
- share/export formatting if easy

Tests should cover:
- duplicate ingredients
- unit conflict behavior
- pantry staple exclusion
- empty list behavior

Do not skip tests for core logic.

---

# EDGE CASES TO HANDLE

The app must gracefully handle:

- empty recipe input
- duplicate recipe names
- network failure
- invalid server response
- missing quantity
- missing unit
- same ingredient with conflicting units
- all items checked
- all items filtered out
- pantry staples only
- obscure recipe names in mock mode

App must never crash from these cases.

---

# PROJECT DELIVERY REQUIREMENTS

Produce:

1. A complete Xcode SwiftUI project
2. Runnable app with mock mode
3. Clear README
4. Config section for switching API base URL / mock mode
5. Sample preview/demo data
6. Unit tests for core logic

README must include:
- project overview
- stack used
- setup instructions
- how mock mode works
- where to set backend URL
- known limitations
- next-step improvements

---

# IMPLEMENTATION ORDER

Follow this exact order.

## Phase 1: Project Setup
- create SwiftUI app
- set up navigation structure
- create app theme basics
- create placeholder screens

## Phase 2: Models + Mock Data
- define DTOs and local models
- build mock ingredient service
- render basic ingredient checklist with mock data

## Phase 3: Core Logic
- implement normalizer
- implement merger
- implement shopping list builder
- add tests

## Phase 4: Checklist UX
- owned toggle
- grouped sections
- edit sheet
- delete support

## Phase 5: Persistence
- save and restore current state
- AppStorage preferences
- clear data flow

## Phase 6: Networking
- add live API service
- error handling
- loading states
- easy mock/live switching

## Phase 7: Shopping List + Share
- grouped shopping list
- copy/share
- empty states

## Phase 8: Polish
- spacing
- labels
- icons
- examples
- user-friendly text
- README cleanup

Do NOT skip straight to networking before mock mode and core logic are working.

---

# ACCEPTANCE CRITERIA

The app is complete when all are true:

1. User can enter multiple recipe names
2. Mock mode works fully without backend
3. Live API mode is implemented cleanly
4. Ingredients are normalized and merged correctly
5. User can mark owned items
6. Shopping list updates immediately
7. User can edit and delete ingredients
8. State survives app restart
9. Shopping list can be copied/shared
10. App looks polished enough for demo use

---

# ENGINEERING RULES

- Prefer simple, readable Swift over clever abstraction
- Keep business logic testable and separated from views
- Use mock-first development
- Make the app resilient to imperfect data
- Do not leave TODO placeholders for core features
- Finish end-to-end flow before adding extras

---

# FINAL INSTRUCTION

Start implementing immediately.

First deliver:
1. SwiftUI app structure
2. Models
3. Mock service
4. Home screen + checklist screen with mock data

Then continue until the full demo app is complete.

Do not stop at scaffolding.
Do not only describe what you would build.
Actually build the project structure and code.