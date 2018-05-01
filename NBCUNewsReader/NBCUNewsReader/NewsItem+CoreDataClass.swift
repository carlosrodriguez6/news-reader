//
//  NewsItem+CoreDataClass.swift
//  CoreDataOne
//
//  Created by Carlos Rodriguez on 4/28/18.
//  Copyright © 2018 Carlos Rodriguez. All rights reserved.
//
//

import Foundation
import CoreData

@objc(NewsItem)
public class NewsItem: NSManagedObject {
    
    static var publishedDateFormatter: DateFormatter = { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"; return f }()
    
    init?(usingJSON json: JSONDictionary, inManagedObjectContext moc: NSManagedObjectContext) {
        
        guard let entity = NSEntityDescription.entity(forEntityName: "NewsItem", in: moc) else {
            //Normally I don't like using fatalError but if we can't load the entity at this point we can't do much
            fatalError("Can't load NewsItem entity from model")
        }
        
        super.init(entity: entity, insertInto: moc)
        
        self.headline = json["headline"] as? String
        self.summary = json["summary"] as? String
        self.url = json["url"] as? String
        self.id = json["id"] as? String
        if let dateString = json["published"] as? String, let publishedDate = NewsItem.publishedDateFormatter.date(from: dateString) {
            self.publishedDate = publishedDate as NSDate
        }
        self.teaseMediaURL = json["tease"] as? String
        self.type = json["type"] as? String
    }
    
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
