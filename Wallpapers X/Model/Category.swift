//
//  Category.swift
//  Wallpapers X
//
//  Created by DanJin on 2019/12/12.
//  Copyright © 2019 sarwatshah. All rights reserved.
//

import Foundation

class Category {
    
    var name = "" // title
    var cover = "" // thumbnail
    
    init(dictionary: [String: AnyObject]) {
        if let name = dictionary["title"] as? String {
            self.name = name
        }
        if let cover = dictionary["thumbnail"] as? String {
            self.cover = cover
        }
    }
    
}
