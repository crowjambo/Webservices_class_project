import Foundation
import Alamofire

enum Errors: Error{
    case failed
}

struct RegisterRequestParemeters: Codable {
    let username: String
    let email: String
    let password: String
    let roles: [String]
}

class MyService {
    
    static let shared = MyService()

    private var token: String?
    private var user: User?
    
    let baseURL: String = "https://www.iosbackendwebservices.fun/wp-json/"
    let postsURL: String = "wp/v2/posts/"
    let authURL: String = "jwt-auth/v1/token?"
    let usersURL: String = "wp/v2/users/"
    
    private init(token: String? = nil){
        self.token = token
    }
    
    typealias PostResponse = (Result<NewPost, Error>) -> Void
    typealias PostsResponse = (Result<[NewPost], Error>) -> Void
    typealias AuthResponse =  (Result<Token?, Error>) -> Void
    typealias UserResponse = (Result<User?,Error>) -> Void
    
    func updateToken(newToken: String) {
        self.token = newToken
    }
    
    // MARK: - POSTS CRUD

    func getPosts(completionHandler: @escaping PostsResponse) {

        guard let url = URL(string: "\(baseURL)\(postsURL)") else { return }
        AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success:
                do {
                    guard let data = response.data else { return }
                    let posts = try JSONDecoder().decode([NewPost].self, from: data)
                    completionHandler(.success(posts))
                } catch {
                    
                }
            case .failure(let err):
                completionHandler(.failure(err))
            }
        }
        
    }
    
    func createPost(title:String, content:String, completionHandler: @escaping PostResponse) {
        guard let token = token else { return }
        guard let url = URL(string: "\(baseURL)\(postsURL)") else { return }
        
        let headers:HTTPHeaders = ["Authorization" : "Bearer \(token)",
                           "Content-Type": "application/json"]
        
        let parameters: [String: String] = [
            "title" : title,
            "content" : content,
            "status": "publish",
        ]

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                do {
                    guard let data = response.data else { return }
                    let post = try JSONDecoder().decode(NewPost.self, from: data)
                    completionHandler(.success(post))
                } catch {
                    
                }
            case .failure(let err):
                completionHandler(.failure(err))
            }
        }
    }
    
    func deletePostById(id: Int, completionHandler: @escaping PostResponse) {
        guard let token = token else { return }
        guard let url = URL(string: "\(baseURL)\(postsURL)\(String(id))") else { return }
        
        let headers:HTTPHeaders = ["Authorization" : "Bearer \(token)",
                           "Content-Type": "application/json"]
        

        AF.request(url, method: .delete, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                do {
                    guard let data = response.data else { return }
                    let post = try JSONDecoder().decode(NewPost.self, from: data)
                    completionHandler(.success(post))
                } catch {
                    
                }
            case .failure(let err):
                completionHandler(.failure(err))
            }
        }
        
    }
    
    // MARK: - USER
    
    func getCurrentUser() -> User? {
        return self.user
    }
    
    func setCurrentUser(user: User) {
        self.user = user
    }
    
    func getMe(completionHandler: @escaping UserResponse) {
        guard let token = token else { return }
        guard let url = URL(string: "\(baseURL)\(usersURL)me") else { return }
        
        let headers:HTTPHeaders = ["Authorization" : "Bearer \(token)",
                           "Content-Type": "application/json"]
        

        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                do {
                    guard let data = response.data else { return }
                    let user = try JSONDecoder().decode(User.self, from: data)
                    self.setCurrentUser(user: user)
                    completionHandler(.success(user))
                } catch {
                    
                }
            case .failure(let err):
                completionHandler(.failure(err))
            }
        }
    }
    
    
    // MARK: - AUTH

    func login(login:String, password:String, completionHandler: @escaping AuthResponse) {
        
        let parameters: [String: String] = [
            "username" : login,
            "password" : password,
        ]
        
        guard let url = URL(string: "\(baseURL)\(authURL)") else { return }
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).responseJSON { (response) in
            switch response.result {
            case .success:
                do {
                    guard let data = response.data else { return }
                    let token = try JSONDecoder().decode(Token.self, from: data)
                    if let trueToken = token.token {
                        self.updateToken(newToken: trueToken)
                             self.getMe { (response) in
                                 completionHandler(.success(token))
                             }
                    } else {
                        completionHandler(.success(nil))
                    }
                }
                catch {
                    
                }
            case .failure(let err):
                completionHandler(.failure(err))
            }
        }

    }
    
    func register(username: String, email: String, password: String, completionHandler: @escaping UserResponse) {
        
        guard let url = URL(string: "\(baseURL)\(usersURL)") else { return }
        
        //need admin token first
        login(login: "user", password: "MjXqvaXmm31S") { (response) in
            
            guard let token = self.token else { return }
            var urlRequest = URLRequest(url: url)
            let reqParameters = RegisterRequestParemeters(username: username, email: email, password: password, roles: ["author"])
             guard let parameters = try? JSONEncoder().encode(reqParameters) else { return }
             urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
             urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
             urlRequest.httpBody = parameters
             urlRequest.httpMethod = "POST"
            
            AF.request(urlRequest).responseJSON { (response) in
                switch response.result {
                case .success:
                    do {
                        guard let data = response.data else { return }
                        let userResponse = try JSONDecoder().decode(User.self, from: data)
                        if userResponse.id == nil {
                            completionHandler(.success(nil))
                        } else {
                            self.login(login: username, password: password) { (response) in
                                completionHandler(.success(userResponse))
                            }
                        }
                    }
                    catch {
                        
                    }
                case .failure(let err):
                    completionHandler(.failure(err))
                }
            }
        }

    }


}


