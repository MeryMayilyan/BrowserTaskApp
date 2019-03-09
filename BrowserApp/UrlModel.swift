//
//  UrlModel.swift
//  BrowserApp
//
//  Created by Shahen on 3/9/19.
//  Copyright © 2019 Shahen. All rights reserved.
//

import Foundation
import RealmSwift

class UrlModel: Object {
    
    @objc dynamic var url : String = ""
    
    override static func primaryKey() -> String? {
        return "url"
    }
}
