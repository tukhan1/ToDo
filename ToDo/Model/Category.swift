//
//  Category.swift
//  ToDo
//
//  Created by Egor Tushev on 15.11.2021.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var backgroundColor: String = ""
    
    let items = List<Item>()
}
