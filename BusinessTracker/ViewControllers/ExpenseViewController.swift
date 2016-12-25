//
//  ExpenseViewController.swift
//  BusinessTracker
//
//  Created by Shuvo on 10/25/16.
//  Copyright © 2016 Shuvo. All rights reserved.
//

import UIKit
import CoreData

class ExpenseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    private var isFirstTxtValid     = false
    private var isSecondTxtValid    = false
    private let productType         = "Expense"
    private let CellIdentifier      = "ExpenseCell"
    private var business:Business!
    private var expenseMonthlyTotal = 0.0
    
    var isDetails:Bool!
    var businessName: String!
    //    private var productList = [Product]()
    private var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak private var instalationTxtFld: UITextField!
    @IBOutlet weak private var expenseTableView: UITableView!
    @IBOutlet weak private var saveButton: UIButton!
    @IBOutlet weak private var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var totalExpenseLbl: UILabel!
    @IBOutlet weak private var totalExpenseResultLbl: UILabel!
    
    
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
            totalExpenseLbl.removeFromSuperview()
            totalExpenseResultLbl.removeFromSuperview()
        }
        
        expenseTableView.tableFooterView = UIView()
        instalationTxtFld.addDoneOnKeyboardWithTarget(self, action: #selector(self.donePressed(_:)))
        saveButton.hidden = isDetails
        saveButton.enabled = !isDetails
        
        // get the newly created business profile To add products on it.
        let request = NSFetchRequest(entityName: "Business")
        request.predicate = NSPredicate(format: "name = %@", businessName)
        do {
            let result = try managedObjectContext.executeFetchRequest(request)
            business = result[0] as! Business
            instalationTxtFld.text = business.instalationCost
        }
        catch {
            fatalError("Error in retreving Business Profiles/list")
        }
        
        
        // fetch the products
        do {
            try self.fetchedResultsController.performFetch()
            
        } catch {
            let fetchError = error as NSError
            DLog("\(fetchError), \(fetchError.userInfo)")
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //loadData()
        if isDetails! {
            showTotalMonthlyExpense()
        }
    }
    
    private func showTotalMonthlyExpense() {
        var tmpTotal = 0.0
        for product in self.fetchedResultsController.fetchedObjects! as! [Product] {
            let cost = product.cost ?? "0.0"
            tmpTotal += Double(cost)!
        }
        expenseMonthlyTotal = tmpTotal
        totalExpenseResultLbl.text = formateNumberToString(expenseMonthlyTotal)
    }
    
    func donePressed(buttun:UIBarButtonItem) {
        self.view.endEditing(true)
        
        business.instalationCost = instalationTxtFld.text!
        do {
            try self.business.managedObjectContext?.save()
        }
        catch {
            fatalError("Error in storing to data")
        }
        
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
     expenseTableView.reloadData()
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
        expenseTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        expenseTableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch(type) {
        case .Insert:
            if let newIndexPath = newIndexPath {
                expenseTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation:.Automatic)
                if isDetails! {
                    showTotalMonthlyExpense()
                }
            }
        case .Delete:
            if let indexPath = indexPath {
                expenseTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                if isDetails! {
                    showTotalMonthlyExpense()
                }
            }
        case .Update:
            if let indexPath = indexPath {
                if let cell = expenseTableView.cellForRowAtIndexPath(indexPath) {
                    configureCell(cell, atIndexPath: indexPath)
                    if isDetails! {
                        showTotalMonthlyExpense()
                    }
                }
            }
        case .Move:
            if let indexPath = indexPath {
                if let newIndexPath = newIndexPath {
                    expenseTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    expenseTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                }
            }
        }
    }
    
    //MARK:- Private Action Methods
    @IBAction private func addExpense(sender: UIBarButtonItem) {
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
            //self.loadData()
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
    
    @IBAction private func saveAndContinue(sender:UIButton) {
        
        guard let _ = instalationTxtFld.text
            where instalationTxtFld.text?.characters.count > 0
            else {
                let alertcontroller = UIAlertController(title: "Must Provide instalation cost", message: nil, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
                }
                
                alertcontroller.addAction(cancelAction)
                
                presentViewController(alertcontroller, animated: true, completion: nil)
                return
        }
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("IncomeViewController") as! IncomeViewController
        controller.businessName = businessName
        controller.isDetails = false
        let navController = UINavigationController(rootViewController: controller)
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
}
