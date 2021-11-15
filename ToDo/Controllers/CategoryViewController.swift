//
//  CategoryViewController.swift
//  ToDo
//
//  Created by Egor Tushev on 08.11.2021.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.reloadData()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellReuseIdentifier: "CategoryCellId")
        
        loadCategories()
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.getIdentifier(), for: indexPath) as! CategoryCell
        
        cell.categoryName.text = categories[indexPath.row].name
        cell.itemsCount.text = String(categories[indexPath.row].itemCount)
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteCategory = UIContextualAction(style: .destructive, title: nil) {  (contextualAction, view, boolValue) in
            
            
            if self.categories[indexPath.row].itemCount != 0 {
                
                let alert = UIAlertController(title: "Delete Category", message: "If you delete this category all items in there will be destroed", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    
                    self.prepareForDeletingCategiry(categoryName: self.categories[indexPath.row].name)
                    
                    
                    self.context.delete(self.categories[indexPath.row])
                    self.categories.remove(at: indexPath.row)
                    
                    
                    self.saveCategories()
                    self.loadCategories()
                    
                    return
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in

                    return
                }))
                
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                self.context.delete(self.categories[indexPath.row])
                self.categories.remove(at: indexPath.row)
                
            }
            
            self.saveCategories()
            self.loadCategories()
            
        }
        
        deleteCategory.image = UIImage(systemName: "trash.fill")
        deleteCategory.backgroundColor = .gray
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteCategory])
        
        return swipeActions
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    
    
    //MARK: - Data Manipulation Methods
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let text = textField.text {
                let newCategory = Category(context: self.context)
                newCategory.name = text
                self.categories.append(newCategory)
                
                self.saveCategories()
            }
        }
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Type there"
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Saving error : \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Loading error : \(error)")
        }
        
        tableView.reloadData()
    }
    
    func prepareForDeletingCategiry(categoryName: String?) {
        
        if let name = categoryName {
            let predicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)
            let request = Item.fetchRequest()
            request.predicate = predicate
            do {
                let itemArray = try context.fetch(request)
                for item in itemArray {
                    
                    context.delete(item)
                    
                }
                
            } catch {
                print("Deleting categort error : \(error)")
            }
            
        }
        
        
    }
}
