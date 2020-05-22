import UIKit
import Alamofire

class ViewController: UIViewController {
    
    
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
}

// MARK: - Table View

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TaskCell
            
        cell.titleLabel.text = tasks[indexPath.row].title
        cell.contentText.text = tasks[indexPath.row].content
            
        //using protocols give reference to each cell to this view controller
//        cell.delegate = self
//        cell.indexP = indexPath.row
        
        // one cell is created
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
        MyService.shared.getPosts { (response) in
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
        //get title and content from input fields here

        MyService.shared.createPost(title: "NEWNEW", content: "newnew2") { (response) in
            switch response {
            case .success(let str):
                print(str)
            case .failure(let err):
                print(err)
            }
        }
    }

}

