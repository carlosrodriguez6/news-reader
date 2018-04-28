//
//  NewsService.swift
//  CoreDataOne
//
//  Created by Carlos Rodriguez on 4/27/18.
//  Copyright © 2018 Carlos Rodriguez. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: Any]
typealias JSONArray = [Any]

class NewsService {

    let rootSession =  URLSession(configuration: .default)
    var headlinesTask: URLSessionDataTask?

    /// Gets an array of items from the NBCU curated feed, parse the and passes them to the completion
    /// handler.
    /// - parameter completion: closure that will receive the **unsaved** article objects
    func getNBCUNews(completion: @escaping ([JSONDictionary]) -> ()) {
        
        headlinesTask?.cancel()
        
        guard let url = URL(string: "http://msgviewer.nbcnewstools.net:9207/v1/query/curation/news/") else {
            completion([])
            return
        }
        
        headlinesTask = rootSession.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                var newsItemsJSON: JSONArray?
                var returnObjects = [JSONDictionary]()
                
                do {
                    newsItemsJSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSONArray
                    
                    //TODO: This serialization should really be an initialization using Codable.  Support ASAP.
                    if let newsItemJSON = newsItemsJSON,
                        let envelope = newsItemJSON.first as? JSONDictionary,
                        let items = envelope["items"] as? JSONArray {
                        for item in items {
                            if let item = item as? JSONDictionary {
                                returnObjects.append(item)
                            }
                        }
                        completion(returnObjects)
                    }
                }
                catch let parseError as NSError {
                    print("JSONSerialization error: \(parseError.localizedDescription)\n")
                    return
                }
            }
        })
        headlinesTask?.resume()
    }
}

