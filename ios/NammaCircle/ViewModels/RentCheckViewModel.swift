import Foundation

@MainActor
final class RentCheckViewModel: ObservableObject {
    @Published var input = RentCheckInput()
    @Published var result: RentCheckResult?
    @Published var isChecking = false
    @Published var errorMessage: String?

    private let service: RentCheckServicing

    init(service: RentCheckServicing = MockRentCheckService()) {
        self.service = service
    }

    func checkRent() {
        Task {
            isChecking = true
            defer { isChecking = false }

            do {
                result = try await service.checkRent(input: input)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
