import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    let baseURL = "https://communitysafety-fd5fa0d9bf0b.herokuapp.com"

    func addUser(name: String, phone: String, trusted_ids: [Int], profile_picture: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "name": name,
            "phone": phone,
            "trusted_ids": trusted_ids,
            "profile_picture": profile_picture
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
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedPhone = phone.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let urlString = "\(baseURL)/users/find?name=\(encodedName)&phone=\(encodedPhone)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 404 else {
                completion(.failure(NSError(domain: "NetworkError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return
            }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode the response"])))
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
    
    func checkAndUpdateUser(user: User, completion: @escaping (Result<User, Error>) -> Void) {
            getFirstUser { result in
                switch result {
                case .success(let firstUser):
                    guard let existingTrustedIds = firstUser.trusted_ids, !existingTrustedIds.contains(user.id) else {
                        completion(.failure(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "This user is already in your trusted list."])))
                        return
                    }
                    
                    var updatedTrustedIds = existingTrustedIds
                    updatedTrustedIds.append(user.id)
                    
                    self.updateFirstUserTrustedContacts(userId: firstUser.id, newContactId: user.id) { updateResult in
                        switch updateResult {
                        case .success(let updatedUser):
                            completion(.success(updatedUser))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    
    func getFirstUser(completion: @escaping (Result<User, Error>) -> Void) {
        // Example API call to fetch the first user
        let url = URL(string: "\(baseURL)/users/first")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: nil)))
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

    func updateFirstUserTrustedContacts(userId: Int, newContactId: Int, completion: @escaping (Result<User, Error>) -> Void) {
        // Example API call to update trusted contacts for a user
        let url = URL(string: "\(baseURL)/users/updateTrustedContacts")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["userId": userId, "newContactId": newContactId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: nil)))
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
    
    func removeContactFromTrusted(userId: Int, contactId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/users/\(userId)/remove-trusted")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["contactId": contactId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No valid HTTP response"])))
                return
            }

            if httpResponse.statusCode == 200 {
                completion(.success(true))
            } else {
                completion(.failure(NSError(domain: "NetworkError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to remove contact"])))
            }
        }.resume()
    }
}
