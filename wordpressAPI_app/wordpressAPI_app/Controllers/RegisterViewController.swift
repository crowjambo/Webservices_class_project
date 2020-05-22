import UIKit
import Alamofire

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var loginBox: UITextField!
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardTap()
    }

    
    @IBAction func submitPressed(_ sender: Any) {
        registerUser()
    }
    
        func registerUser() {
            guard
                let login = loginBox.text,
                let password = passwordBox.text,
                let email = emailBox.text
            else { return }
            
            MyService.shared.register(username: login, email: email, password: password) { (response) in
                switch response {
                case .success(let user):
                    if user != nil {
                        print("welcome \(user?.name ?? "corruptedName") | ID: \(user?.id ?? 0)")
                        self.performSegue(withIdentifier: "TasksSegueFromRegister", sender: self)
                    } else {
                        print("register failed")
                    }
                case .failure(let err):
                    print(err)
                }
            }
        }

}
