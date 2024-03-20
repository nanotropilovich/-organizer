
import Foundation
struct Record: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var text: String
}
