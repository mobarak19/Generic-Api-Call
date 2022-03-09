

import UIKit

class ViewController: UIViewController {

    struct Constants {
        
        static let userUrl = URL(string: "https://jsonplaceholder.typicode.com/users")
        static let todoListUrl = URL(string: "https://jsonplaceholder.typicode.com/todos")

    }
    
    let table : UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var models: [Any] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        view.addSubview(table)
        table.dataSource = self
        table.delegate = self
        
        //fetchUsers()
        fetchTodos()
        
    }
    func fetchUsers()  {
        URLSession.shared.request(url: Constants.userUrl, expecting: [User].self) {[weak self] result  in
            switch result{
            case .success(let users):
                self?.models = users
                DispatchQueue.main.async {
                    self?.table.reloadData()
                }
            case .failure(let error):
                print(error)
            }
            print(result)
        }
    }
    func fetchTodos()  {
        URLSession.shared.request(url: Constants.todoListUrl, expecting: [Todo].self) {[weak self] result  in
            switch result{
            case .success(let users):
                self?.models = users
                DispatchQueue.main.async {
                    self?.table.reloadData()
                }
            case .failure(let error):
                print(error)
            }
            print(result)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds

    }

}

extension ViewController: UITableViewDelegate,  UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
 
        let model = models[indexPath.row]
        
        if model is User{
            cell.textLabel?.text = (model as! User).name
        }else{
            cell.textLabel?.text = (model as! Todo).title
            if (model as! Todo).completed {
                cell.accessoryType = .checkmark
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
extension URLSession {
    enum CustomError : Error {
        case invalidUrl
        case invalidData
    }
    
    func request<T: Codable>(
    url : URL?,
    expecting: T.Type,
    completion: @escaping (Result<T,Error>) -> Void){
        guard let url = url else {
            completion(.failure(CustomError.invalidUrl))
            return
        }
        let task = dataTask(with: url) { data, _, error in
            guard let data = data else {
                if let error = error {
                    completion(.failure(error))
                }else{
                    completion(.failure(CustomError.invalidData))
                }
                return
            }
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            }catch{
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

struct User: Codable {
    let name:String
    let email:String
}
struct Todo: Codable {
    let title:String
    let completed:Bool
}
