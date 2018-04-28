//
//  MasterViewController.swift
//  CoreDataOne
//
//  Created by Carlos Rodriguez on 4/27/18.
//  Copyright © 2018 Carlos Rodriguez. All rights reserved.
//

import CoreData
import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [NewsItem]()
    
    var managedObjectContext: NSManagedObjectContext?
    
    var dataService: NewsService?

    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO: factor this out.
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        loadHeadlines()
    }
    
    func loadHeadlines() {
        
        guard let moc = managedObjectContext else {
            return
        }
        
        dataService?.getNBCUNews(completion: { (headlines) in
            DispatchQueue.main.async {
                
                do {
                    for jsonDictionary in headlines {
                        if let newsItem = NewsItem(usingJSON: jsonDictionary, inManagedObjectContext: moc) {
                            self.objects.append(newsItem)
                        }
                    }
                    try moc.save()
                    self.tableView.reloadData()
                }
                catch let error as NSError {
                    print("Error: \(error) saving news items")
                }
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let newsItem = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.contentURL = newsItem.url
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                newsItem.read = true
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}

extension MasterViewController {
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let object = objects[indexPath.row]
        
        if let headline = object.headline {
            cell.textLabel?.text = headline
        }
        if object.read == true {
            cell.textLabel?.textColor = UIColor.gray
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //TODO: Replace this with a custom editing action to mark as read.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

