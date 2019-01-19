//
//  Item.swift
//  Todoey by Ankur
//
//  Created by Ankur Almadi on 1/18/19.
//  Copyright © 2019 Ankur Almadi. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
