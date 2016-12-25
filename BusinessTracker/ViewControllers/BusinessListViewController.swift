//
//  BusinessListViewController.swift
//  BusinessTracker
//
//  Created by Shuvo on 10/25/16.
//  Copyright © 2016 Shuvo. All rights reserved.
//

import UIKit
import CoreData

class BusinessListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let cellIdentifier = "MyCell"
    private var businessList = [Business]()
    
    var managedObjectContext: NSManagedObjectContext!
    
    
    @IBOutlet weak private var businessTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        businessTableView.tableFooterView = UIView()
        
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appdelegate.coreData.managedObjectContext
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    func loadData() {
        let request = NSFetchRequest(entityName: "Business")
        do {
            let result = try managedObjectContext.executeFetchRequest(request)
            businessList = result as! [Business]
            businessTableView.reloadData()
        }
        catch {
            fatalError("Error in retreving Business Profiles/list")
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        let row = indexPath.row
        let business = businessList[row]
        
        cell.textLabel?.text = business.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("DetailsViewController") as! DetailsViewController
        let row = indexPath.row
        let business = businessList[row]
        controller.businessName = business.name
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func createBusinessProfile(sender: UIBarButtonItem) {
        let alertcontroller = UIAlertController(title: "Create Profile", message: nil, preferredStyle: .Alert)
        alertcontroller.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Enter Profile Name"
        }
        
        let createAction = UIAlertAction(title: "Create", style: .Default) { (action) in
            let textField = alertcontroller.textFields?.first
             DLog(textField!.text!)
            
            let business = NSEntityDescription.insertNewObjectForEntityForName("Business", inManagedObjectContext: self.managedObjectContext) as! Business
            
            business.name = textField!.text!
            
            do {
                try self.managedObjectContext.save()
            }
            catch {
                fatalError("Error in storing to data")
            }
            
            //self.loadData()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("ExpenseViewController") as! ExpenseViewController
            controller.businessName = textField!.text!
            controller.isDetails = false
            let navController = UINavigationController(rootViewController: controller)
            self.presentViewController(navController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // aletcontroller.dismiss(animated: true, completion: nil)
        }
        
        alertcontroller.addAction(createAction)
        alertcontroller.addAction(cancelAction)
        
        presentViewController(alertcontroller, animated: true, completion: nil)
    }
    
}
