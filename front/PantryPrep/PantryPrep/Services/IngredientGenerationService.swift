import Foundation

struct IngredientGenerationService {
    enum ServiceError: LocalizedError {
        case liveAPINotYetImplemented

        var errorDescription: String? {
            switch self {
            case .liveAPINotYetImplemented:
                return "Live API will be wired in Phase 8. Keep useMock = true."
            }
        }
    }

    func generate(
        recipes: [String],
        servings: Int,
        includePantryStaples: Bool
    ) async throws -> [IngredientDTO] {
        if AppConfig.useMock {
            return await MockIngredientService.generate(
                recipes: recipes,
                servings: servings,
                includePantryStaples: includePantryStaples
            )
        }
        throw ServiceError.liveAPINotYetImplemented
    }
}
