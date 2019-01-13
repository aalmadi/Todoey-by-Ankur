//
//  ViewController.swift
//  Todoey by Ankur
//
//  Created by Ankur Almadi on 1/6/19.
//  Copyright © 2019 Ankur Almadi. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory : Category? {
        didSet{
            loadItems(predicate: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - TableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(indexPath.row)
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - Add a New Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let addItemController = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let addItemAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
        }
        
        addItemController.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create a new item"
            textField = alertTextField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        addItemController.addAction(addItemAction)
        addItemController.addAction(cancelAction)
        present(addItemController, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    func saveItems() {
        do {
            try context.save()
        }catch {
            print("Error saving items \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate?) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate])
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching results from context, \(error)")
        }
        tableView.reloadData()
    }
}

//MARK: - Search Bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems(predicate: nil)
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

