//
//  NewsItem+CoreDataProperties.swift
//  CoreDataOne
//
//  Created by Carlos Rodriguez on 4/28/18.
//  Copyright © 2018 Carlos Rodriguez. All rights reserved.
//
//

import Foundation
import CoreData

extension NewsItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsItem> {
        return NSFetchRequest<NewsItem>(entityName: "NewsItem")
    }

    @NSManaged public var id: String?
    @NSManaged public var type: String?
    @NSManaged public var url: String?
    @NSManaged public var headline: String?
    @NSManaged public var publishedDate: NSDate?
    @NSManaged public var teaseMediaURL: String?
    @NSManaged public var summary: String?
    @NSManaged public var read: Bool

}
