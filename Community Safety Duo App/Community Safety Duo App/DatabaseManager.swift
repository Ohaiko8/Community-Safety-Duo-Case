import MongoSwiftSync
import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private var client: MongoClient?
    private var database: MongoDatabase?
    private var usersCollection: MongoCollection<User>?
    
    init() {
        do {
            // Initialize MongoDB client
            self.client = try MongoClient("your_mongodb_connection_string")
            self.database = client?.db("your_database_name")
            self.usersCollection = database?.collection("users", withType: User.self)
        } catch {
            print("Failed to initialize MongoDB client: \(error)")
        }
    }
    
    deinit {
        // Clean up resources by closing the MongoDB client
        try? self.client?.syncClose()
    }
    
    func addUser(_ user: User, completion: @escaping (Result<ObjectId, Error>) -> Void) {
        do {
            let result = try usersCollection?.insertOne(user)
            if let insertedId = result?.insertedID.as(ObjectId.self) {
                completion(.success(insertedId))
            } else {
                completion(.failure(DatabaseError.insertionFailed))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchUser(byId id: ObjectId, completion: @escaping (Result<User?, Error>) -> Void) {
        do {
            let user = try usersCollection?.findOne(["_id": .objectId(id)])
            completion(.success(user))
        } catch {
            completion(.failure(error))
        }
    }
}

enum DatabaseError: Error {
    case insertionFailed
}

// Model conforming to Codable for MongoDB operations
struct User: Codable {
    let id: ObjectId
    let name: String
    let phone: String
    let trustedIDs: [String]
    let profilePicture: Data
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", name, phone, trustedIDs, profilePicture
    }
}
