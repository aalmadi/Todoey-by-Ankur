//
//  CategoryViewController.swift
//  Todoey by Ankur
//
//  Created by Ankur Almadi on 1/12/19.
//  Copyright © 2019 Ankur Almadi. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        loadCategories()
    }
    
    //MARK: - TableView Data Source Methods
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
//        cell.delegate = self
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let categoryCell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        let categoryCell = super.tableView(tableView, cellForRowAt: indexPath)
        categoryCell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet"
        if let categoryColor = UIColor(hexString: categories![indexPath.row].backgroundColor) {
            categoryCell.backgroundColor = categoryColor
            categoryCell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        } else {
            categoryCell.backgroundColor = UIColor(hexString: "1D9BF6")
        }
        return categoryCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    
    //MARK: - Data Manipulation Methods
    
    func save(category : Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving new category, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    

    //MARK: - Add a category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var categoryTextField = UITextField()
        let categoryAddController = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let categoryAddAction = UIAlertAction(title: "Add Category", style: .default) { (alertAction) in
            let newCategory = Category()
            newCategory.name = categoryTextField.text!
            newCategory.backgroundColor = UIColor.randomFlat.hexValue()
            self.save(category: newCategory)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        categoryAddController.addTextField { (textField) in
            textField.placeholder = "Create a new category"
            categoryTextField = textField
        }
        categoryAddController.addAction(categoryAddAction)
        categoryAddController.addAction(cancelAction)
        present(categoryAddController, animated: true, completion: nil)
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
}

//MARK: - Category Search Methods

extension CategoryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        categories = categories?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadCategories()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
