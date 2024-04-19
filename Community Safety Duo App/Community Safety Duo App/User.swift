import Foundation
import RealmSwift
import MongoSwift

struct User: Codable {
    var id: ObjectId  // Corrected type for MongoDB Object ID
    var name: String
    var phone: String
    var trustedIDs: [String]
    var profilePicture: BSONBinary?  // Store image as binary data

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, phone, trustedIDs, profilePicture
    }
    
    // Custom initializer to handle decoding from BSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(ObjectId.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.trustedIDs = try container.decode([String].self, forKey: .trustedIDs)
        self.profilePicture = try container.decodeIfPresent(BSONBinary.self, forKey: .profilePicture)
    }
    
    // Encoding function to convert the instance into BSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(phone, forKey: .phone)
        try container.encode(trustedIDs, forKey: .trustedIDs)
        try container.encodeIfPresent(profilePicture, forKey: .profilePicture)
    }
}
