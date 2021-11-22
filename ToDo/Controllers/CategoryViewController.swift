//
//  CategoryViewController.swift
//  ToDo
//
//  Created by Egor Tushev on 08.11.2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        let logo = UIImage(named: "logo.png")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        imageView.contentMode = .scaleAspectFill
        imageView.image = logo
        self.navigationItem.titleView = imageView
        
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .darkGray
        
        loadCategories()
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Catigories added yet"
        
        if let color = categories?[indexPath.row].backgroundColor {
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: color)!, returnFlat: true)
            cell.backgroundColor = UIColor(hexString: color)
        }
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    
    //MARK: - Data Manipulation Methods
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let text = textField.text {
                let newCategory = Category()
                newCategory.name = text.capitalized
                newCategory.backgroundColor = UIColor.randomFlat().hexValue()
                
                self.save(category: newCategory)
            }
        }
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Type there"
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Saving category error : \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let object = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(object)
                }
            } catch {
                print("Deleting category error \(error)")
            }
        }
    }
}
