//
//  Databasehelper.swift
//  jenniferbuur_pset5
//
//  Created by Jennifer Buur on 21-03-17.
//  Copyright © 2017 Jennifer Buur. All rights reserved.
//

import Foundation
import SQLite

class DatabaseHelper {
    
    private let lists = Table("lists")
    private let todoList = Table("todoList")
    
    private let listItem = ListItem()
    private let todoItem = TodoItem()
    
    static let sharedInstance = DatabaseHelper()
    
    private var db: Connection?
    
    init?() {
        do {
            try setUpDatabase()
        } catch {
            print(error)
            return nil
        }
    }
    
    private func setUpDatabase() throws {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        do {
            db = try Connection("\(path)/db.sqlite3")
            try createTable()
        } catch {
            throw error
        }
    }
    
    private func createTable() throws {
        do {
            try db!.run(lists.create(ifNotExists: true) { t in
                t.column(listItem.listNames, unique: true)
            })
            try db!.run(todoList.create(ifNotExists: true) { t in
                t.column(todoItem.listNames)
                t.column(todoItem.todoNames)
                t.column(todoItem.cleared)
            })
        } catch {
            throw error
        }
    }
    
    func count(list: String, tableName: String) throws -> Int {
        do {
            if tableName == "todoList" {
                let filter = todoList.filter(todoItem.listNames == list)
                return try db!.scalar(filter.count)
            } else {
                return try db!.scalar(lists.count)
            }
        } catch {
            throw error
        }
    }
    
    func search(tableName: String, list: String) throws -> [String] {
        var result = [String]()
        do {
            if tableName == "todoList" {
                let filter = todoList.filter(todoItem.listNames == list)
                for row in try db!.prepare(filter) {
                    result.append(row[todoItem.todoNames])
                }
            } else {
                for row in try db!.prepare(lists) {
                    result.append(row[listItem.listNames])
                }
            }
        } catch {
            throw error
        }
        return result
    }
    
    func searchClears(list: String) throws -> [Int] {
        var result = [Int]()
        do {
            let filter = todoList.filter(todoItem.listNames == list)
            for row in try db!.prepare(filter) {
                result.append(row[todoItem.cleared])
            }
        } catch {
            throw error
        }
        return result
    }
    
    func add(tableName: String, title: String, list: String) throws {
        do {
            if tableName == "todoList" {
                try db!.run(todoList.insert(todoItem.todoNames <- title, todoItem.listNames <- list, todoItem.cleared <- 0))
            } else {
                try db!.run(lists.insert(listItem.listNames <- list))
            }
        } catch {
            throw error
        }
    }
    
    func delete(tableName: String, name: String) throws {
        do {
            if tableName == "todoList" {
                let item = todoList.filter(todoItem.todoNames == name)
                try db!.run(item.delete())
            } else {
                let item = lists.filter(listItem.listNames == name)
                try db!.run(item.delete())
            }
        } catch {
            throw error
        }
    }
    
    func update(todoName: String, list: String) throws {
        do {
            let filter = todoList.filter(todoItem.listNames == list && todoItem.todoNames == todoName)
            let update = filter.update(todoItem.cleared <- 1)
            try db!.run(update)
        } catch {
            throw error
        }
    }
}
