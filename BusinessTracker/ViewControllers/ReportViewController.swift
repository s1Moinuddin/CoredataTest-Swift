//
//  ReportViewController.swift
//  BusinessTracker
//
//  Created by Shuvo on 10/26/16.
//  Copyright © 2016 Shuvo. All rights reserved.
//

import UIKit
import CoreData

class ReportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var businessName:String!
    
    @IBOutlet weak private var expenseTotalLbl: UILabel!
    @IBOutlet weak private var incomeTotalLbl: UILabel!
    @IBOutlet weak private var yearTxtFld: UITextField!
    @IBOutlet weak private var reportBtn: UIButton!
    @IBOutlet weak private var reportTableView: UITableView!
    
    private var expenseMonthlyTotal = 0.0
    private var incomeMonthlyTotal = 0.0
    private var initialExpense = 0.0
    private var tableData = [String]()
    
    var managedObjectContext: NSManagedObjectContext!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        reportTableView.tableFooterView     = UIView()
        reportTableView.estimatedRowHeight  = 72
        reportTableView.rowHeight           = UITableViewAutomaticDimension
        
        expenseTotalLbl.text    = String(expenseMonthlyTotal)
        incomeTotalLbl.text     = String(incomeMonthlyTotal)
        
        let appdelegate         = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext    = appdelegate.coreData.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Business")
        request.predicate = NSPredicate(format: "name = %@", businessName)
        do {
            let result = try managedObjectContext.executeFetchRequest(request)
            let currentBusiness = result[0] as! Business
            let array = currentBusiness.product?.allObjects.map({ $0 as! Product})
            
            initialExpense = Double(currentBusiness.instalationCost!)!
            
            var expenseArr  = [Product]()
            var incomeArr   = [Product]()
            
            if array != nil {
                expenseArr = array!.filter({ $0.type == "Expense"})
                incomeArr = array!.filter({ $0.type == "Income"})
            }

            if expenseArr.count > 0 {
                for product in expenseArr {
                    let cost = product.cost ?? "0.0"
                    expenseMonthlyTotal += Double(cost)!
                }
            }
            
            if incomeArr.count > 0 {
                for product in incomeArr {
                    let cost = product.cost ?? "0.0"
                    incomeMonthlyTotal += Double(cost)!
                }
            }
            
            expenseTotalLbl.text = formateNumberToString(expenseMonthlyTotal) //String(expenseMonthlyTotal)
            incomeTotalLbl.text = formateNumberToString(incomeMonthlyTotal) //String(incomeMonthlyTotal)
            
            
        }
        catch {
            fatalError("Error in retreving Business Profiles/list")
        }
        
    }

    @IBAction func generateReport(sender: UIButton) {
        
        if yearTxtFld.text?.characters.count == 0 {
            return
        }
        
        self.view.endEditing(true)
        
        let year = Double(yearTxtFld.text!)!
        
        let yearlyExpense = ((expenseMonthlyTotal * 12) * year) + initialExpense
        let yearlyIncome = (incomeMonthlyTotal * 12) * year
        
        let difference = yearlyIncome - yearlyExpense
        let ratio = (difference/yearlyExpense) * 100
        let ratioStr = formateNumberToString(ratio) //String(format: "%.2f", ratio)
        
        let reportString = "\(year) year total expense = \(formateNumberToString(yearlyExpense)) \n\(year) year total income = \(formateNumberToString(yearlyIncome)) \nDifference = \(formateNumberToString(difference)) \nNPR = \(ratioStr)%"
        
        //tableData.append(reportString)
        tableData.insert(reportString, atIndex: 0)
        
        // Update Table Data
        reportTableView.beginUpdates()
        reportTableView.insertRowsAtIndexPaths([
            NSIndexPath(forRow: 0, inSection: 0)
            ], withRowAnimation: .Automatic) //tableData.count-1
        reportTableView.endUpdates()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReportCell", forIndexPath: indexPath) as! ReportTableViewCell
        cell.reportLabel.text = tableData[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

}
