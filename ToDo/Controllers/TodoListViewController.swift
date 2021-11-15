//
//  ViewController.swift
//  ToDo
//
//  Created by Egor Tushev on 22.10.2021.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    let k = K()
    
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: k.cellIdetifire, for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .destructive, title: nil) {  (contextualAction, view, boolValue) in
            
            self.context.delete(self.itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
            self.updateCounter(update: false)
            
            self.saveItems()
            self.loadItems()
        }
        
        contextItem.image = UIImage(systemName: "trash.fill")
        
        contextItem.backgroundColor = .gray
        
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        
        return swipeActions
    }
    
    
    //MARK: - Tableview Delegate Methods
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    
    
    //MARK: - Data Manipulation Methods
    
    
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        
        let alert = UIAlertController(title: k.alertTitle, message: k.emptyString, preferredStyle: .alert)
        
        let action = UIAlertAction(title: k.alertActionTitle, style: .default) { (action) in
            
            if let text = textField.text {
                
                let newItem = Item(context: self.context)
                newItem.title = text
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                
                
                
                self.itemArray.append(newItem)
                self.updateCounter(update: true)
                self.saveItems()
                
                
            }
        }
        
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = self.k.alertPlaceholder
            textField = alertTextField
        }
        
        
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("\(error)")
        }
        
        self.tableView.reloadData()
    }
    

    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [categoryPredicate, additionalPredicate])
            
            request.predicate = compoundPredicate
            
        } else {
            
            request.predicate = categoryPredicate
            
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func updateCounter(update yes: Bool) {
        if yes {
            self.selectedCategory?.itemCount += 1
        } else {
            self.selectedCategory?.itemCount -= 1
        }
    }
}




//MARK: - Searchbar Methods


extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: request.predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
