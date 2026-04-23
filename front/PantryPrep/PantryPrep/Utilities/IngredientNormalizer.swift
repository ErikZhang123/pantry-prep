import Foundation

enum IngredientNormalizer {
    private static let synonyms: [String: String] = [
        "scallion": "green onion",
        "scallions": "green onion",
        "spring onion": "green onion",
        "spring onions": "green onion",
    ]

    static func normalize(_ raw: String) -> String {
        let cleaned = raw.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let mapped = synonyms[cleaned] { return mapped }
        let singular = singularize(cleaned)
        if let mapped = synonyms[singular] { return mapped }
        return singular
    }

    private static func singularize(_ s: String) -> String {
        if s.hasSuffix("oes"), s.count > 3 {
            return String(s.dropLast(2))
        }
        if s.hasSuffix("ies"), s.count > 3 {
            return String(s.dropLast(3)) + "y"
        }
        if s.hasSuffix("s"),
           !s.hasSuffix("ss"),
           !s.hasSuffix("us"),
           !s.hasSuffix("is") {
            return String(s.dropLast())
        }
        return s
    }
}
