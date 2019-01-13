//
//  CategoryViewController.swift
//  Todoey by Ankur
//
//  Created by Ankur Almadi on 1/12/19.
//  Copyright © 2019 Ankur Almadi. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    //MARK: - TableView Data Source Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryCell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        categoryCell.textLabel?.text = categories[indexPath.row].name
        return categoryCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    
    //MARK: - Data Manipulation Methods
    
    func saveCategories() {
        do {
            try context.save()
        }catch {
            print("Error saving category, (\(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        }catch {
            print("Error fetching categories, \(error)")
        }
        tableView.reloadData()
    }
    

    //MARK: - Add a category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var categoryTextField = UITextField()
        let categoryAddController = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let categoryAddAction = UIAlertAction(title: "Add Category", style: .default) { (alertAction) in
            let category = Category(context: self.context)
            category.name = categoryTextField.text
            self.categories.append(category)
            self.saveCategories()
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
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
}

//MARK: - Category Search Methods

extension CategoryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        loadCategories(with: request)
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
