import UIKit
import Alamofire

class ViewController: UIViewController {
    
    let service = MyService()
    var tasks: [Task] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    @IBAction func buttonClicked(_ sender: Any) {
        loadPosts()
    }
    
    @IBAction func redButtonClicked(_ sender: Any) {
        createPost()
    }
    @IBAction func loginBtnClicked(_ sender: Any) {
        loginUser()
    }
}

// MARK: - Table View

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // inflate/create cells of a certain custom type using TodoCell identifier(place them there)
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TaskCell
            
            // set that new cell values
        cell.titleLabel.text = tasks[indexPath.row].title
        cell.contentText.text = tasks[indexPath.row].content
            
        //using protocols give reference to each cell to this view controller
//        cell.delegate = self
//        cell.indexP = indexPath.row
        
        // one cell is created
        return cell
    }
    
    //table view delegate swipe to remove method (editing styles in general, can catch all of them here)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        //editing style is the deleting swipe
        if(editingStyle == UITableViewCell.EditingStyle.delete){
            removeTask(idNumber: indexPath.row)
        }
    }
    
    
}

// MARK: - Table methods

extension ViewController{
    
    private func resetTasksFully(){
        self.service.getPosts { (response) in
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
        service.deletePostById(id: wpID) { (response) in
            self.resetTasksFully()
        }
    }
    
    // delegate/interface from AddTaskController (receives data from Another controller using interfaces)
    func addTask(title: String, content: String) {
        service.createPost(title: title, content: content) { (response) in

        }
    }
    
    // update/edit method for each task cell task object
//    func updateTask(name:String, description:String, indexPath: Int){
//        tasks[indexPath].name = name
//        tasks[indexPath].description = description
//
//        updateTableView()
//    }
    
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
//        service.getPosts { (response) in
//            switch response {
//            case .success(let posts):
//                for post in posts {
//                    guard let id = post.id,
//                        let title = post.title,
//                        let content = post.content
//                    else { return }
//                    print("\(id) \(title.html2String) \(content.html2String)")
//                }
//            case .failure(let err):
//                print(err)
//            }
//        }
    }
    
    func createPost() {
        //get title and content from input fields here

        service.createPost(title: "NEWNEW", content: "newnew2") { (response) in
            switch response {
            case .success(let str):
                print(str)
            case .failure(let err):
                print(err)
            }
        }
    }
    
    func loginUser() {
        
        let auth = AuthService()
        auth.login(login: "user", password: "MjXqvaXmm31S") { (response) in
            switch response {
            case .success(let tok):
                print("successfully logged in, returned token - \(tok!.token!)")
                self.service.updateToken(newToken: tok!.token!)
            case .failure(let err):
                print(err)
            }
        }
    }
}

