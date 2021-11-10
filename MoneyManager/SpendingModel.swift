//
//  SpendingModel.swift
//  MoneyManager
//
//  Created by Иван on 11/8/21.
//

import RealmSwift

class Spending: Object {
    
    @objc dynamic var category = ""
    @objc dynamic var cost = 1
    @objc dynamic var date = NSDate()
    
}

class Limit: Object {
    
    @objc dynamic var limitSum = ""
    @objc dynamic var limitDate = NSDate()
    @objc dynamic var limitLastDay = NSDate()
}
