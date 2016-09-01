//
//  OurStoryTableViewController.swift
//  saveDateLocationPhoto
//
//  Created by Diana on 8/28/16.
//  Copyright © 2016 diana. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class OurStoryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate  {
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        self.refreshControl = pullToRefreshControl
        refreshControl?.addTarget(self, action: #selector(OurStoryTableViewController.refreshData), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    // MARK: - Outlets
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    // MARK: - Refresh Control
    let pullToRefreshControl = UIRefreshControl()
    
    func refreshData() {
        initializeFetchedResultsController()
        
    }
    
    // MARK: - Core Data
    var managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchedResultsController: NSFetchedResultsController!
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: "Entity")
        let sortByDate = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sortByDate]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: "dateAsSectionName", cacheName: nil)
        self.fetchedResultsController.delegate = self
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    
    
    // MARK: - Table view data source
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let timeline = fetchedResultsController.objectAtIndexPath(indexPath) as! Entity
        let cell = cell as! OurStoryTableViewCell
        
        cell.storyEntryLabel.text = timeline.entry
        cell.storyLocationLabel.text = timeline.location
        
        
        if timeline.date != nil {
           cell.storyDateLabel.text = NSDateFormatter.localizedStringFromDate(
                NSDate(),
                dateStyle: NSDateFormatterStyle.LongStyle,
                timeStyle: NSDateFormatterStyle.ShortStyle);
        }
        
        if let image = timeline.image {
            cell.storyImageView.image = UIImage(data: image)
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ourStoryTableViewCells", forIndexPath: indexPath) as! OurStoryTableViewCell
        // Set up the cell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchedResultsController.sections
        let sectionInfo = sections![section]
        return sectionInfo.numberOfObjects
    }
    
    
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // delete it from core data
        let managedObject = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        managedObjectContext.deleteObject(managedObject)
        // save to core data
        do {
            try self.managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = UILabel()
        let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        
        title.text = sectionInfo.name
        title.font = UIFont(name: "HelveticaNeue", size: 14)
        title.textColor = UIColor(hue: 0.48, saturation: 0.06, brightness: 0.44, alpha: 1)
        title.backgroundColor = UIColor(hue:0.00, saturation:0.00, brightness:0.97, alpha:1.00)
        title.textAlignment = NSTextAlignment.Center
        
        return title
    }
    
    
    //    // Override to support rearranging the table view.
    //    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    //
    //    }
    
    
    //    // Override to support conditional rearranging of the table view.
    //    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    //        // Return false if you do not want the item to be re-orderable.
    //        return true
    //    }
    //
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
