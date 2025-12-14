
import Foundation

struct PicsumImage: Codable, Identifiable, Equatable {
    let id: String
    let author: String
    let width: Int?
    let height: Int?
    let url: String?
    let download_url: String?

    // Deterministic coordinate from id
    var coordinate: (lat: Double, lon: Double) {
        return DeterministicCoordinate.from(seed: id)
    }
}

