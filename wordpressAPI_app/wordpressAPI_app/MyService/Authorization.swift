import Foundation
import Alamofire


class AuthService {
    
    let authURL: String = "https://www.iosbackendwebservices.fun/wp-json/jwt-auth/v1/token?"
    typealias AuthResponse =  (Result<Token?>) -> Void
    
    func login(login:String, password:String, completionHandler: @escaping AuthResponse) {
        
        let parameters: [String: String] = [
            "username" : login,
            "password" : password,
        ]
        
        guard let url = URL(string: authURL) else { return }
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).responseJSON { (response) in
            switch response.result {
            case .success:
                do {
                    guard let data = response.data else { return }
                    let token = try JSONDecoder().decode(Token.self, from: data)
                    completionHandler(.success(token))
                }
                catch {
                    
                }
            case .failure:
                if let error = response.error {
                    print(error)
                }
            }
        }

    }
    
}
