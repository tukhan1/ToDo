//
//  Item.swift
//  ToDo
//
//  Created by Egor Tushev on 15.11.2021.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var date: Date = Date()
    
    var perentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
