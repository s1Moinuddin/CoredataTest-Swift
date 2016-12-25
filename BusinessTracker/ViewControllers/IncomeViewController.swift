//
//  IncomeViewController.swift
//  BusinessTracker
//
//  Created by Shuvo on 10/25/16.
//  Copyright © 2016 Shuvo. All rights reserved.
//

import UIKit
import CoreData

class IncomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,NSFetchedResultsControllerDelegate {
    
    private var isFirstTxtValid     = false
    private var isSecondTxtValid    = false
    private let productType         = "Income"
    private let CellIdentifier      = "IncomeCell"
    private var business:Business!
    private var incomeMonthlyTotal = 0.0
    
    var isDetails:Bool!
    var businessName: String!
    //var productList = [Product]()
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak private var incomeTableView: UITableView!
    @IBOutlet weak private var finishButton: UIButton!
    @IBOutlet weak private var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak private var totalIncomeLbl: UILabel!
    @IBOutlet weak private var totalIncomeResultLbl: UILabel!
    
    //MARK:- FetchedResults Controller
    lazy private var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Product")
        //fetchRequest.fetchLimit = 100
        fetchRequest.fetchBatchSize = 20
        
        // Filter Product where type is expense and Business is self.businessName
        var typePredicate = NSPredicate(format: "type = %@", self.productType)
        var businessPredicate = NSPredicate(format: "business.name = %@", self.businessName)
        
        let andPredicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [typePredicate, businessPredicate])
        fetchRequest.predicate = andPredicate
        
        // Sort by createdAt
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appdelegate.coreData.managedObjectContext
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableViewBottomConstraint.constant = isDetails! ? 0 : 50
        
        if !isDetails! {
            incomeTableView.tableHeaderView = UIView()
        }
        
        incomeTableView.tableFooterView = UIView()
        finishButton.hidden = isDetails
        finishButton.enabled = !isDetails
        
        // get the newly created business profile To add products on it.
        let request = NSFetchRequest(entityName: "Business")
        request.predicate = NSPredicate(format: "name = %@", businessName)
        do {
            let result = try managedObjectContext.executeFetchRequest(request)
            business = result[0] as! Business
        }
        catch {
            fatalError("Error in retreving Business Profiles/list")
        }
        
        // fetch the products
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //loadData()
        if isDetails! {
            showTotalMonthlyIncome()
        }
    }
    
    private func showTotalMonthlyIncome() {
        var tmpTotal = 0.0
        for product in self.fetchedResultsController.fetchedObjects! as! [Product] {
            let cost = product.cost ?? "0.0"
            tmpTotal += Double(cost)!
        }
        incomeMonthlyTotal = tmpTotal
        totalIncomeResultLbl.text = formateNumberToString(incomeMonthlyTotal)
    }
    
    /*
     func loadData() {
     let request = NSFetchRequest(entityName: "Business")
     request.predicate = NSPredicate(format: "name = %@", businessName)
     do {
     let result = try managedObjectContext.executeFetchRequest(request)
     let currentBusiness = result[0] as! Business
     let array = currentBusiness.product?.allObjects.map({ $0 as! Product})
     
     if array != nil {
     productList = array!.filter({ $0.type == self.productType})
     incomeTableView.reloadData()
     }
     
     }
     catch {
     fatalError("Error in retreving Business Profiles/list")
     }
     }*/
    
    // MARK:- TableView DataSource Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return productList.count
        if let currSection = fetchedResultsController.sections?[section] {
            return currSection.numberOfObjects
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)
        
        /*let row = indexPath.row
         let product = productList[row]
         cell.textLabel?.text = product.name
         cell.detailTextLabel?.text = product.cost*/
        
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    // A private method to configure cell at indexPath
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Configure cell with the product model
        let product = fetchedResultsController.objectAtIndexPath(indexPath) as! Product
        cell.textLabel?.text = product.name
        cell.detailTextLabel?.text = product.cost
    }
    
    // MARK:- Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        incomeTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        incomeTableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch(type) {
        case .Insert:
            if let newIndexPath = newIndexPath {
                incomeTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation:.Automatic)
                if isDetails! {
                    showTotalMonthlyIncome()
                }
            }
        case .Delete:
            if let indexPath = indexPath {
                incomeTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                if isDetails! {
                    showTotalMonthlyIncome()
                }
            }
        case .Update:
            if let indexPath = indexPath {
                if let cell = incomeTableView.cellForRowAtIndexPath(indexPath) {
                    configureCell(cell, atIndexPath: indexPath)
                    if isDetails! {
                        showTotalMonthlyIncome()
                    }
                }
            }
        case .Move:
            if let indexPath = indexPath {
                if let newIndexPath = newIndexPath {
                    incomeTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    incomeTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                }
            }
        }
    }
    
    //MARK:- Private Action Methods
    @IBAction private func addIncome(sender: UIBarButtonItem) {
        let alertcontroller = UIAlertController(title: "Add Product and Cost", message: nil, preferredStyle: .Alert)
        alertcontroller.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Enter Name"
            textField.tag = 1
            textField.addTarget(self, action: #selector(self.textChanged(_:)), forControlEvents: .EditingChanged)
        }
        alertcontroller.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Enter Price"
            textField.keyboardType = .DecimalPad
            textField.tag = 2
            textField.addTarget(self, action: #selector(self.textChanged(_:)), forControlEvents: .EditingChanged)
        }
        
        let addAction = UIAlertAction(title: "Add", style: .Default) { (action) in
            let textFieldName = alertcontroller.textFields?.first
            let textFieldCost = alertcontroller.textFields?.last
            
            let product = NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: self.managedObjectContext) as! Product
            
            product.createdAt = NSDate()
            product.name = textFieldName!.text!
            product.cost = textFieldCost!.text!
            product.type = self.productType
            
            let products = self.business.mutableSetValueForKey("product")
            products.addObject(product)
            //self.business.product = NSSet(object: product)
            
            do {
                try self.business.managedObjectContext?.save()
            }
            catch {
                fatalError("Error in storing to data")
            }
            // self.loadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // aletcontroller.dismiss(animated: true, completion: nil)
        }
        addAction.enabled = false
        
        alertcontroller.addAction(addAction)
        alertcontroller.addAction(cancelAction)
        
        presentViewController(alertcontroller, animated: true, completion: nil)
    }
    
    func textChanged(sender: AnyObject) {
        let tf = sender as! UITextField
        if tf.tag == 1 {
            isFirstTxtValid = (tf.text != "")
        } else if tf.tag == 2 {
            isSecondTxtValid = (tf.text != "")
        } else {
            isSecondTxtValid = false
            isFirstTxtValid = false
        }
        // enable OK button only if there is text
        // hold my beer and watch this: how to get a reference to the alert
        var resp : UIResponder! = tf
        while !(resp is UIAlertController) { resp = resp.nextResponder() }
        let alert = resp as! UIAlertController
        alert.actions[0].enabled = (isFirstTxtValid && isSecondTxtValid)
    }
    
    @IBAction private func finishAction(sender:UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("BusinessListViewController") as! BusinessListViewController
        let navController = UINavigationController(rootViewController: controller)
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    
}
