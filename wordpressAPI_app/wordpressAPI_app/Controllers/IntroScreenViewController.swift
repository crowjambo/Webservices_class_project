import UIKit
import Alamofire

extension UIViewController {
    func setupKeyboardTap() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

class IntroScreenViewController: UIViewController {
    
    @IBOutlet weak var loginBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardTap()
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        loginUser()
    }
    
    // MARK: - AUTH
    
    func loginUser() {
        guard
            let login = loginBox.text,
            let password = passwordBox.text
        else { return }
        
//        login: "user", password: "MjXqvaXmm31S"
        MyService.shared.login(login: login, password: password) { (response) in
            switch response {
            case .success(let tok):
                if tok != nil {
                    print("successfully logged in, returned token - \(tok!.token!)")
                    print("\n\n-----\n\nUSER ID: ")
                    print(MyService.shared.getCurrentUser()!.id!)
                    self.performSegue(withIdentifier: "TasksSegue", sender: self)
                } else {
                    print("logging in failed")
                }
            case .failure(let err):
                print(err)
               
            }
        }
    }

}

