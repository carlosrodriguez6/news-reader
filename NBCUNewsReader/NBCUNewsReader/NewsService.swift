//
//  NewsService.swift
//  CoreDataOne
//
//  Created by Carlos Rodriguez on 4/27/18.
//  Copyright © 2018 Carlos Rodriguez. All rights reserved.
//

import CoreData
import Foundation

typealias JSONDictionary = [String: Any]
typealias JSONArray = [Any]

class NewsService {

    let rootSession =  URLSession(configuration: .default)
    var headlinesTask: URLSessionDataTask?
    var managedObjectContext: NSManagedObjectContext?

    /// Gets an array of items from the NBCU curated feed, parse the and passes them to the completion
    /// handler.    
    func downloadHeadlines(completion: @escaping () -> Void) {
        
        headlinesTask?.cancel()
        
        guard let url = URL(string: "http://msgviewer.nbcnewstools.net:9207/v1/query/curation/news/") else {
            completion()
            return
        }
        
        headlinesTask = rootSession.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                let newsItemsJSONArray: JSONArray?
                
                do {
                    let newsItemsJSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSONArray
                    newsItemsJSONArray = self.extractNewsItemsFromPayload(newsItemsJSON)
                }
                catch let parseError as NSError {
                    print("JSONSerialization error: \(parseError.localizedDescription)\n")
                    return
                }
                
                if let moc = self.managedObjectContext, let items = newsItemsJSONArray {
                    for case let item as JSONDictionary in items {
                        _ = NewsItem(usingJSON: item, inManagedObjectContext: moc)
                    }
                }
                
                do {
                    try self.managedObjectContext?.save()
                }
                catch let error {
                    print("Core data error: \(error.localizedDescription)")
                    completion()
                    return
                }
                completion()
            }
        })
        headlinesTask?.resume()
    }
    
    fileprivate func extractNewsItemsFromPayload(_ json: JSONArray?) -> JSONArray? {
        guard let json = json, json.isEmpty == false,
            let envelope = json.first as? JSONDictionary,
            let items = envelope["items"] as? JSONArray else {
            return nil
        }
        return items
    }
}

