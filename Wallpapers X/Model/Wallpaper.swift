//
//  Wallpaper.swift
//  Wallpapers X
//
//  Created by DanJin on 2019/12/13.
//  Copyright © 2019 sarwatshah. All rights reserved.
//

import Foundation

class Wallpaper {

    var key = "" // record key
    var id = 0
    var name = "" // title
    var thumbnail = "" // thumbnail
    var origin = "" // url
    var category = "" // category
    var datetime: Int64 = 0
    var downloads = 0
    var favorites = 0
    var hashtags = "" // desc
    
    init() {
        self.key = ""
        self.id = 0
        self.name = ""
        self.thumbnail = ""
        self.origin = ""
        self.category = ""
        self.hashtags = ""
        self.downloads = 0
        self.favorites = 0
        self.datetime = 0
    }
    
    init(key: String, dictionary: [String: AnyObject]) {
        self.key = key
        if let id = dictionary["id"] as? Int {
            self.id = id
        }
        if let name = dictionary["title"] as? String {
            self.name = name
        }
        if let thumbnail = dictionary["url"] as? String {
            self.thumbnail = thumbnail
        }
        if let origin = dictionary["url"] as? String {
            self.origin = origin
        }
        if let category = dictionary["category"] as? String {
            self.category = category
        }
        if let hashtags = dictionary["desc"] as? String {
            self.hashtags = hashtags
        }
        if let downloads = dictionary["downloads"] as? Int {
            self.downloads = downloads
        }
        if let favorites = dictionary["favorites"] as? Int {
            self.favorites = favorites
        }
        if let datetime = dictionary["datetime"] as? Int64 {
            self.datetime = datetime
        }
    }
    
    func getDictionary() -> Dictionary<String, Any> {
        let wallObject = ["id": self.id, "title": self.name,
                          "thumbnail": self.thumbnail, "url": self.origin,
                          "category": self.category, "desc": self.hashtags,
                          "downloads": self.downloads, "favorites": self.favorites,
                          "datetime": self.datetime] as [String : Any]
        return wallObject as [String : Any]
    }
    
}
