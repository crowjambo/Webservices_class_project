import Foundation
import Alamofire

enum Errors: Error{
    case failed
}

class MyService {
    
    private var token: String?
    
    init(token: String? = nil){
        self.token = token
    }
    
    let baseURL: String = "https://www.iosbackendwebservices.fun/wp-json/"
    let postsURL: String = "wp/v2/posts/"
    
    typealias PostResponse = (Result<String>) -> Void
    
    func updateToken(newToken: String) {
        self.token = newToken
    }

    func getPosts(completionHandler: @escaping (Result<[Post]>) -> Void ) {
        Post.list { (response: Result<[Post]>) in
            switch response {
            case .success(let posts):
                completionHandler(.success(posts))
            case .failure(let err):
                print(err)
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
                completionHandler(.success("success"))
            case .failure:
                completionHandler(.failure(Errors.failed))
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
                completionHandler(.success("success"))
            case .failure:
                completionHandler(.failure(Errors.failed))
            }
        }
        
    }


}
