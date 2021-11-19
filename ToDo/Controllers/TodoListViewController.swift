//
//  ViewController.swift
//  ToDo
//
//  Created by Egor Tushev on 22.10.2021.
//

import UIKit
import RealmSwift

class TodoListViewController: SwipeTableViewController {
    
    let k = K()
    
    let realm = try! Realm()
    
    var todoItems : Results<Item>?
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    //MARK: - Tableview Datasource Methods
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    
    //MARK: - Tableview Delegate Methods
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    
    
    //MARK: - Data Manipulation Methods
    
    
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        
        let alert = UIAlertController(title: k.alertTitle, message: k.emptyString, preferredStyle: .alert)
        
        let action = UIAlertAction(title: k.alertActionTitle, style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                if let text = textField.text {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = text.capitalized
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                        print("Error saving new item : \(error)")
                    }
                }
            }
            
            self.tableView.reloadData()
        }
        
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = self.k.alertPlaceholder
            textField = alertTextField
        }
        
        
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let object = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(object)
                }
            } catch {
                print("Deleting item error : \(error)")
            }
        }
    }
}




//MARK: - Searchbar Methods


extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "date", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
