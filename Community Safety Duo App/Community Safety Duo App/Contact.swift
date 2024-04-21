import Foundation

struct Contact: Decodable, Identifiable {
    var id: Int
    var name: String
    var phone: String
    var trusted_ids: [Int]?
    var profile_picture: String?
}
