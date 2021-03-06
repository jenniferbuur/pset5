//
//  ViewController.swift
//  jenniferbuur_pset5
//
//  Created by Jennifer Buur on 16-03-17.
//  Copyright © 2017 Jennifer Buur. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UITableViewController {
    
    var secondViewController: SecondViewController? = nil
    var lists = [String]()
    var row = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewList(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        setUpDatabase()
        createTable()
        self.searchAll()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: create database and table
    private var db: Connection?
    let list = Table("list")
    let listNames = Expression<String>("listNames")
    
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
            try db!.run(list.create(ifNotExists: true) { t in
                t.column(listNames, unique: true)
            })
        } catch {
            alertUser(title: "Oops", message: "Failed to create table")
            print("Failed to create table: \(error)")
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
    
    // MARK: to search database for todos
    func searchAll() {
        lists.removeAll()
        do {
            for name in try db!.prepare(list) {
                if name[listNames].isEmpty != true {
                    lists.append(name[listNames])
                }
            }
        } catch {
            print("Did not find anything: \(error)")
        }
    }

    func addNewList(_ sender: Any) {
        
        // http://stackoverflow.com/questions/26567413/get-input-value-from-textfield-in-ios-alert-in-swift
        let alert = UIAlertController(title: "Add a new list", message: "Enter the name of your new list", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Listname"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            print("Text field: \(textField?.text)")
            
            if textField?.text! == "" {
                print("Empty String")
            } else {
                let insert = self.list.insert(self.listNames <- (textField?.text!)!)
                do {
                    try self.db!.run(insert)
                } catch {
                    self.alertUser(title: "Oops", message: "Could not create new list")
                    print("Error creating list: \(error)")
                }
                self.searchAll()
                self.tableView.reloadData()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: tableviewdatasource
    // making tableview
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let newCell = tableView.dequeueReusableCell(withIdentifier: "firstCell") as! firstCustomCell
        
        newCell.listName.text = lists[indexPath.row]
        
        return newCell
    }
    
    // editing tableview
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let item = list.filter(listNames == lists[indexPath.row])
            do {
                try db!.run(item.delete())
                searchAll()
            } catch {
                print("Could not delete list: \(error)")
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        row = indexPath.row
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let secondViewController = navigationController.viewControllers.first! as! SecondViewController
        secondViewController.listName = self.lists[tableView.indexPathForSelectedRow!.row]
    }
}
