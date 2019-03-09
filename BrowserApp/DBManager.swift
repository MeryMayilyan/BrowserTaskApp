//
//  DBManager.swift
//  BrowserApp
//
//  Created by Shahen on 3/9/19.
//  Copyright © 2019 Shahen. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit

class DBManager {
    
    private var database:Realm
    static let sharedInstance = DBManager()

    
    private init() {
        database = try! Realm()
    }
    
    func getDataFromDB() -> [String] {
        let results: Results<UrlModel> = database.objects(UrlModel.self)
        var tempArr = [String]()
        for result in results {
            tempArr.append(result.url)
        }
        return tempArr
    }
    
    func addData(object: UrlModel) {
        try! database.write {
            database.add(object, update: true)
            print("Added new object")
        }
        
    }
    
//    func deleteAllDatabase()  {
//        try! database.write {
//            database.deleteAll()
//        }
//    }
    
    func deleteFromDb(index: Int) {
        try! database.write {
            database.delete(database.objects(UrlModel.self)[index])
        }
    }
    
}


