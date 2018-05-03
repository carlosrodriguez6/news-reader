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
    var managedObjectContext: NSManagedObjectContext?
    var dataService: NewsService?
    var model: HeadlineListModel?

    
    @IBAction func refreshAction(_ sender: UIRefreshControl) {
        
        dataService?.downloadHeadlines {
            self.model?.refresh()
            
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO: factor this out.
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        if let managedObjectContext = managedObjectContext {
            model = HeadlineListModel(withManagedObjectContext: managedObjectContext)
        }
        loadHeadlines()
    }
    
    func loadHeadlines() {
        
        dataService?.downloadHeadlines {
            self.model?.refresh()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        self.model?.refresh()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let newsItem = model?.fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.contentURL = newsItem?.url
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                newsItem?.read = true
                managedObjectContext?.perform {
                    newsItem?.read = true
                }
                try? managedObjectContext?.save()
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}

extension MasterViewController {
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model?.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let object = model?.fetchedResultsController.object(at: indexPath)
        
        if let type = object?.type {
            switch type {
            case "article":
                cell.imageView?.image = #imageLiteral(resourceName: "Article")
            case "video":
                cell.imageView?.image = #imageLiteral(resourceName: "ic_ondemand_video")
            case "slideshow":
                cell.imageView?.image = #imageLiteral(resourceName: "ic_slideshow")
            default:
                break
            }
        }

        if let headline = object?.headline {
            cell.textLabel?.text = headline
        }
        if let date = object?.publishedDate {
            cell.detailTextLabel?.text = NewsItem.publishedDateFormatter.string(from: date as Date)
        }
        if object?.read == true {
            cell.textLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.textColor = UIColor.gray
        }
        else {
            cell.textLabel?.textColor = UIColor.darkText
            cell.detailTextLabel?.textColor = UIColor.darkText
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

