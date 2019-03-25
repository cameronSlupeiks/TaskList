//
//  ViewController.swift
//  TaskList
//
//  Created by cam on 2019-03-20.
//  Copyright © 2019 cam. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.didTapAddItemButton(_:)))
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:1.00, green:0.98, blue:1.00, alpha:1.0)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SinhalaSangamMN-Bold", size: 24)!]
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        
        do {
            self.todoItems = try [ToDoItem].readFromPersistence()
        } catch let error as NSError {
            
            if error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError {
                NSLog("No persistence file found, not necesserially an error...")
            } else {
                
                let alert = UIAlertController(
                    title: "Error",
                    message: "Could not load the to-do items!",
                    preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                NSLog("Error loading from persistence: \(error)")
            }
        }
    }
    
    private var todoItems = [ToDoItem]()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_todo", for: indexPath)
        cell.textLabel?.font = UIFont(name: "SinhalaSangamMN", size: 19)
            
        if indexPath.row < todoItems.count {
                
            let item = todoItems[indexPath.row]
            cell.textLabel?.text = item.title
                
            let accessory: UITableViewCell.AccessoryType = item.done ? .checkmark : .none
            cell.accessoryType = accessory
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
            
        if indexPath.row < todoItems.count {
            
            let item = todoItems[indexPath.row]
            item.done = !item.done
                
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    private func addNewToDoItem(title: String) {
        
        let newIndex = todoItems.count
        
        todoItems.append(ToDoItem(title: title))
        
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .top)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if indexPath.row < todoItems.count {
            
            todoItems.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .top)
        }
    }
    
    @objc
    func didTapAddItemButton(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(
            title: "New Task",
            message: "Insert Title:",
            preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let title = alert.textFields?[0].text {
                self.addNewToDoItem(title: title)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc
    public func applicationDidEnterBackground(_ notification: NSNotification) {
        
        do {try todoItems.writeToPersistence()}
            
        catch let error {NSLog("Error writing to persistence: \(error)")}
    }
}
