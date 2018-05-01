//
//  HeadlineListModel.swift
//  NBCUNewsReader
//
//  Created by Carlos Rodriguez on 4/30/18.
//  Copyright © 2018 Carlos Rodriguez. All rights reserved.
//

import CoreData
import Foundation

class HeadlineListModel: NSObject, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController<NewsItem>!
    
    init(withManagedObjectContext context: NSManagedObjectContext) {
        let request: NSFetchRequest<NewsItem> = NewsItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "publishedDate", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context,
                                                              sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func refresh() {

        do {
            try fetchedResultsController.performFetch()
        }
        catch let fetchError {
            print("\(fetchError)")
        }
    }
}
