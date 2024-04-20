import Foundation

struct Contact: Decodable, Identifiable {
    var id: Int
    var name: String
    var phone: String
    var trusted_ids: [Int]?  // Ensure this is optional if it can be empty
    var profile_picture: String?  // This should be a String if it's just the name
}
