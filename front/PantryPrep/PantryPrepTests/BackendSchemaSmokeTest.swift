import Foundation
import Testing
@testable import PantryPrep

struct BackendSchemaSmokeTest {
    @Test func backendResponseDecodesIntoDTO() async throws {
        let baseURL = URL(string: "http://localhost:8000")!
        let request = try buildRequest(baseURL: baseURL)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            print("⚠️ [SMOKE TEST SKIPPED] backend unreachable at \(baseURL.absoluteString) — \(error.localizedDescription)")
            return
        }

        guard let http = response as? HTTPURLResponse else {
            Issue.record("Unexpected non-HTTP response")
            return
        }

        guard http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            Issue.record("Backend returned HTTP \(http.statusCode). Is ANTHROPIC_API_KEY set? Body: \(body)")
            return
        }

        let decoded = try JSONDecoder().decode(GenerateResponse.self, from: data)
        #expect(!decoded.ingredients.isEmpty)

        for dto in decoded.ingredients {
            #expect(!dto.id.isEmpty)
            #expect(!dto.displayName.isEmpty)
            #expect(!dto.canonicalName.isEmpty)
            #expect(!dto.recipeName.isEmpty)
        }

        print("✅ [SMOKE TEST HIT BACKEND] decoded \(decoded.ingredients.count) ingredients — schema aligned")
    }

    private func buildRequest(baseURL: URL) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent("generate-ingredients"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        request.httpBody = try JSONEncoder().encode(GenerateRequest(
            recipes: ["Tomato Scrambled Eggs"],
            servings: 2,
            includePantryStaples: false
        ))
        return request
    }
}
