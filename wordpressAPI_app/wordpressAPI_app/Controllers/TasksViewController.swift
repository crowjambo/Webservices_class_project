import UIKit
import Alamofire

class ViewController: UIViewController {
    
    
    var tasks: [Task] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var createTaskView: UIView!
    @IBOutlet weak var contentBox: UITextField!
    @IBOutlet weak var titleBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        welcomeLabel.text = "Hello! \(MyService.shared.getCurrentUser()?.name ?? "failed to load")"
        createTaskView.isHidden = true
        setupKeyboardTap()
        resetTasksFully()
    }


    @IBAction func createPressed(_ sender: Any) {
        createTaskView.isHidden = false

    }
    
    @IBAction func loadPressed(_ sender: Any) {
        loadPosts()
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        createTaskView.isHidden = true
        createPost()
    }
}

// MARK: - Table View

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TaskCell
        cell.titleLabel.text = tasks[indexPath.row].title.html2String
        cell.contentText.text = tasks[indexPath.row].content.html2String
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if(editingStyle == UITableViewCell.EditingStyle.delete){
            removeTask(idNumber: indexPath.row)
        }
    }
    
    
}

// MARK: - Table methods

extension ViewController{
    
    private func resetTasksFully(){
        MyService.shared.getPostsByAuthor { (response) in
            switch response {
            case .success(let posts):
                self.tasks.removeAll()
                for post in posts {
                    self.tasks.append(post.ToTask())
                }
                self.updateTableView()
            case .failure:
                print("failed")
            }
        }
    }
    
    func removeTask(idNumber:Int){
        let wpID = tasks[idNumber].id
        print("id in table \(idNumber), id in WP \(wpID)")
        MyService.shared.deletePostById(id: wpID) { (response) in
            self.resetTasksFully()
        }
    }
    
    func addTask(title: String, content: String) {
        MyService.shared.createPost(title: title, content: content) { (response) in

        }
    }
        
    func updateTableView(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - API Calls

extension ViewController {
    func loadPosts() {
        resetTasksFully()
    }
    
    func createPost() {
        guard let title = titleBox.text,
            let content = contentBox.text
        else { return }
        MyService.shared.createPost(title: title, content: content) { (response) in
            switch response {
            case .success(let str):
                print(str)
                self.resetTasksFully()
            case .failure(let err):
                print(err)
            }
        }
    }

}

