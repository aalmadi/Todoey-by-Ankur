//
//  Category.swift
//  Todoey by Ankur
//
//  Created by Ankur Almadi on 1/18/19.
//  Copyright © 2019 Ankur Almadi. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    let items = List<Item>()
}
