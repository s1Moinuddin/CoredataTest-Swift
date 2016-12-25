//
//  DetailsViewController.swift
//  BusinessTracker
//
//  Created by Shuvo on 10/25/16.
//  Copyright © 2016 Shuvo. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var businessName:String!
    let CellIdentifier = "DetailsCell"
    let tableData = ["Expence", "Income", "Report"]
    
    @IBOutlet weak private var detailTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = businessName
        detailTableView.tableFooterView = UIView()

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)
        
        cell.textLabel?.text = tableData[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("ExpenseViewController") as! ExpenseViewController
            controller.businessName = businessName
            controller.isDetails = true
            self.navigationController?.pushViewController(controller, animated: true)
            
            break
        case 1:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("IncomeViewController") as! IncomeViewController
            controller.businessName = businessName
            controller.isDetails = true
            self.navigationController?.pushViewController(controller, animated: true)
        
            break

        case 2:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("ReportViewController") as! ReportViewController
            controller.businessName = businessName
            self.navigationController?.pushViewController(controller, animated: true)
        
            break

        default:
            break
        }
    }

}
