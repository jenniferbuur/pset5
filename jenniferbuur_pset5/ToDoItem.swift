//
//  TodoItem.swift
//  jenniferbuur_pset5
//
//  Created by Jennifer Buur on 17-03-17.
//  Copyright © 2017 Jennifer Buur. All rights reserved.
//

import Foundation
import SQLite

class TodoItem {
    
    let listNames = Expression<String>("listNames")
    let todoNames = Expression<String>("todoNames")
    let cleared = Expression<Int>("cleared")
}
