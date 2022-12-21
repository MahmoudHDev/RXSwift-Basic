//
//  ViewController.swift
//  RXSwift-secondProj
//
//  Created by Mahmoud Hashim on 12/21/22.
//

import UIKit

import RxSwift
import RxCocoa

struct Users: Codable {
    var username: String?
    var name: String?
    var id: Int?
}

struct UsersViewModel {
    var items = PublishSubject<[Users]>()
    
    func fetchUsers() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {return}
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let safeData = data, error == nil else {return}
            
            do {
                let decodedData = try JSONDecoder().decode([Users].self, from: safeData)
                items.onNext(decodedData)
                
            }catch{
                print("Error has been occured \(error)")
            }
        }
        dataTask.resume()
    }
}


class ViewController: UIViewController {
    //MARK:- Properties

    private let bag = DisposeBag()
    private let viewModelObj = UsersViewModel()
    
    var tableView: UITableView = {
       let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return table
    }()
    
    //MARK:- View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.bounds
        view.addSubview(tableView)
        
        bindData()
    }
    
    //MARK:- Methods
    private func bindData() {
        // calling the fetchUsers() Method
        viewModelObj.fetchUsers()
        // bind the items to the tableView
        viewModelObj.items.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { row, model, cell in
            cell.textLabel?.text = model.username
            
        }.disposed(by: bag)
        
        // selected Row At
        tableView.rx.modelSelected(Users.self)
            // OnNext to specify what happens when the usersobj is recieved
            .subscribe { (usersObj) in
                let userDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "UsersDetailsViewController") as UsersDetailsViewController
                userDetailsVC.titleName = usersObj.username ?? "No Name"
                self.navigationController?.pushViewController(userDetailsVC, animated: true)
                
            } onError: { (err) in
                print(err)
            } onCompleted: {
                print("Users Details Completed (enum)")
            }.disposed(by: bag)

        // selected ==> to get the indexPath
        tableView.rx.itemSelected.subscribe { (indexPath) in
            print(indexPath.element?.row)
        }.disposed(by: bag)

    }
}

