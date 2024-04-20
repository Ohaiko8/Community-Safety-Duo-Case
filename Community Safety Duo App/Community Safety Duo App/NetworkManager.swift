import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    let baseURL = "https://communitysafety-fd5fa0d9bf0b.herokuapp.com"

    func addUser(name: String, phone: String, trustedIds: [Int], profilePicture: Data, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "name": name,
            "phone": phone,
            "trustedIds": trustedIds,
            "profilePicture": profilePicture.base64EncodedString()
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error occurred: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                print("No data received or data could not be serialized.")
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received or data could not be serialized."])))
                return
            }

            print("Response from server: \(responseString)")

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                print("JSON Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchUsers(completion: @escaping (Result<[Contact], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let users = try JSONDecoder().decode([Contact].self, from: data)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Add more functions for other API calls as needed
}
