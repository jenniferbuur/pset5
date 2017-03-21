//
//  SecondViewController.swift
//  jenniferbuur_pset5
//
//  Created by Jennifer Buur on 16-03-17.
//  Copyright © 2017 Jennifer Buur. All rights reserved.
//

import UIKit
import SQLite

class SecondViewController: UITableViewController {
    
    var listName = String()
    var todos = [String]()
    var clears = [Int]()
    var row = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTodo(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        
        setUpDatabase()
        createTable()
        searchAll()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: create database and table
    private var db: Connection?
    let todoList = Table("todoList")
    let listNames = Expression<String>("listNames")
    let todoNames = Expression<String>("todoNames")
    let cleared = Expression<Int>("cleared")
    
    // making database
    private func setUpDatabase() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        do {
            db = try Connection("\(path)/db.sqlite3")
        } catch {
            alertUser(title: "Oops", message: "Could not connect to database")
            print("Cannot connect to database: \(error)");
        }
    }
    
    // making table
    private func createTable() {
        do {
            try db!.run(todoList.create(ifNotExists: true) { t in
                t.column(listNames)
                t.column(todoNames)
                t.column(cleared)
            })
        } catch {
            alertUser(title: "Oops", message: "Failed to create table")
            print("Failed to create table: \(error)")
        }
    }
    
    // MARK: to search database for todos
    func searchAll() {
        todos.removeAll()
        clears.removeAll()
        do {
            for todo in try db!.prepare(todoList) {
                if todo[todoNames].isEmpty != true {
                    if todo[listNames] == listName {
                        todos.append(todo[todoNames])
                        clears.append(todo[cleared])
                    }
                }
            }
        } catch {
            print("Did not find anything: \(error)")
        }
    }
    
    //MARK: alertuser function
    func alertUser(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        return
    }
    
    func addNewTodo(_ sender: Any) {
        
        // http://stackoverflow.com/questions/26567413/get-input-value-from-textfield-in-ios-alert-in-swift
        let alert = UIAlertController(title: "Add a new todo", message: "Enter the name of your new todo", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Todoname"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            print("Text field: \(textField?.text)")
            
            if textField?.text! == "" {
                print("Empty String")
            } else {
                let insert = self.todoList.insert(self.listNames <- self.listName, self.todoNames <- (textField?.text!)!, self.cleared <- 0)
                do {
                    try self.db!.run(insert)
                } catch {
                    self.alertUser(title: "Oops", message: "Could not create new todo")
                    print("Error creating todo: \(error)")
                }
                self.searchAll()
                self.tableView.reloadData()
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func todoCleared(_ sender: UISwitch) {
        let row = sender.tag
        let clear = todoList.filter(todoNames == todos[row] &&
        listNames == listName)
        let update = clear.update(cleared <- 1)
        do {
            try db!.run(update)
        } catch {
            print("Error updating todo: \(error)")
        }
        searchAll()
    }
    
    
    //MARK: tableviewdatasource
    // making tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let newCell = tableView.dequeueReusableCell(withIdentifier: "secondCell") as! secondCustomCell
        
        newCell.todoName.text = todos[indexPath.row]
        if clears[indexPath.row] == 1 {
            newCell.doneSwitch.setOn(true, animated: true)
        }
        
        return newCell
    }
    
    // editing tableview
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let item = todoList.filter(todoNames == todos[indexPath.row])
            do {
                try db!.run(item.delete())
                searchAll()
            } catch {
                print("Could not delete todo: \(error)")
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        row = indexPath.row
    }
}
