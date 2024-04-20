struct User: Codable {
    var id: Int
    var name: String
    var phone: String
    var trustedIds: [Int]?
    var profilePicture: String?
}
