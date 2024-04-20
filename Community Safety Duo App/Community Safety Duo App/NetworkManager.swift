import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    let baseURL = "https://communitysafety-fd5fa0d9bf0b.herokuapp.com"

    func addUser(name: String, phone: String, trustedIds: [Int], profilePicture: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "name": name,
            "phone": phone,
            "trustedIds": trustedIds,
            "profilePicture": profilePicture
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error occurred: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 201 else {
                print("Failed to add user. Status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                completion(.failure(NSError(domain: "Invalid response", code: -2, userInfo: nil)))
                return
            }

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                print("JSON Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let users = try JSONDecoder().decode([User].self, from: data)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchUserByNameAndPhone(name: String, phone: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/find?name=\(name)&phone=\(phone)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError()))
                return
            }
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchTrustedContacts(forUserId userId: Int, completion: @escaping (Result<[Contact], Error>) -> Void) {
            let url = URL(string: "\(baseURL)/users/trusted?userId=\(userId)")!
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

    func updateFirstUserTrustedContacts(trustedId: Int, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/update-first")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["trustedId": trustedId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError()))
                return
            }
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
