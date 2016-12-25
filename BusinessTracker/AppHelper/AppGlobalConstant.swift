//
//  AppGlobalConstant.swift
//  RaasForce
//
//  Created by Shuvo on 7/31/16.
//  Copyright © 2016 Shuvo. All rights reserved.
//

import Foundation
import UIKit

/*
 add dependencie for carthage github "onevcat/Rainbow" ~> 1.1
 You also need to use XcodeColors Plugin to use colored text in console
 XcodeColors: https://github.com/robbiehanson/XcodeColors
 Rainbow: https://github.com/onevcat/Rainbow
 */

typealias DICTIONARY        = [String:AnyObject]

let SEARCH_BAR_HEIGHT       = 44.0
let STATUS_BAR_HEIGHT       = 20.0
let NAV_BAR_HEIGHT          = 64.0
let TAB_BAR_HEIGHT          = 49.0

let DRAWER_WIDTH            = 270.0

let EMAIL_TOKEN             = "EMAIL_TOKEN"
let PASSWORD_TOKEN          = "PASSWORD_TOKEN"
let NAME_TOKEN              = "NAME_TOKEN"
let ACESS_TOKEN             = "ACESS_TOKEN"

let IS_IPAD                 = UIDevice.currentDevice().userInterfaceIdiom == .Pad
let IS_IPHONE               = UIDevice.currentDevice().userInterfaceIdiom == .Phone

#if (arch(i386) || arch(x86_64)) && os(iOS)
let IS_SIMULATOR = true
#else
let IS_SIMULATOR = false
#endif

func unwrap(any:Any) -> Any {
    
    let mi = Mirror(reflecting: any)
    if mi.displayStyle != .Optional {
        return any
    }
    
    if mi.children.count == 0 {
        print("nil parameter/object passed to unwrap, returning Null. CHECK IT IF NEEDED")
        
        return NSNull()
    }
    let (_, some) = mi.children.first!
    return some
    
}

// MARK:- Debug Log/print for SWIFT 2.3
// https://github.com/ArtSabintsev/Magic

func DLog<T>(object: T, _ file: String = #file, _ function: String = #function, _ line: Int = #line)
{
    #if DEBUG
        let fileString = file as NSString
        let fileLastPathComponent = fileString.lastPathComponent as NSString
        let filename = fileLastPathComponent.stringByDeletingPathExtension
        print("\(filename).\(function)[\(line)]: \(object)\n", terminator: "")
    #else
        print("")
    #endif
}

// MARK:- Format number with decimal style
func formateNumberToString(number:Double) -> String {
    let formatter: NSNumberFormatter = NSNumberFormatter()
    formatter.numberStyle = .DecimalStyle
    formatter.maximumFractionDigits = 2
    let formattedStr: NSString = formatter.stringFromNumber(NSNumber(double: number))!
    return formattedStr as String
}

// MARK:- PATH CONSTANTS
// http://www.theappguruz.com/blog/working-ios-file-management-using-swift
// http://stackoverflow.com/questions/16561779/nssearchpathfordirectoriesindomains-nsuserdomainmask

//Documents
let DOCUMENT_PATHS                = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
let Document_FOLDER: AnyObject    = DOCUMENT_PATHS[0]
let DataPath                      = Document_FOLDER.stringByAppendingPathComponent("MyFolder")

//Library
let LIBRARY_PATHS                = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true)
let LIBRARY_FOLDER: AnyObject    = LIBRARY_PATHS[0]
let COUNTRY_PATH                 = LIBRARY_FOLDER.stringByAppendingPathComponent("country.json")


// MARK:- COLOR CONSTANTS
func UIColorFromRGB(rgb: Int, alpha: Float) -> UIColor {
    //#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
    let red = CGFloat(Float(((rgb>>16) & 0xFF)) / 255.0)
    let green = CGFloat(Float(((rgb>>8) & 0xFF)) / 255.0)
    let blue = CGFloat(Float(((rgb>>0) & 0xFF)) / 255.0)
    let alpha = CGFloat(alpha)
    
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
}

let SHADOW_COLOR                 = UIColor.lightGrayColor()
let NAVNBAR_BACKGROUND_COLOR     = UIColorFromRGB(0x4a90e2, alpha: 1.0)
let NAVNBAR_TEXT_COLOR           = UIColor(red: 1.0 / 255.0, green: 125.0 / 255.0, blue: 1.0 / 255.0, alpha: 1.0)
let BODY_COLOR                   = UIColor(red: 219.0 / 255.0, green: 219.0 / 255.0, blue: 219.0 / 255.0, alpha: 1.0)
let APP_BLUE_COLOR               = UIColorFromRGB(0x4a90e2, alpha: 1.0)

func SHADOW_SMALL_3D(view:UIView) {
    
    view.layer.shadowColor      = SHADOW_COLOR.CGColor
    view.layer.shadowOffset     = CGSize(width: 0.1, height: 0.1)
    view.layer.shadowRadius     = 2.0
    view.layer.shadowOpacity    = 0.3
    view.alpha                  = 0.98
}

func APP_BORDER_COLOR(view:UIView) {
    
    view.layer.borderColor = UIColor(white: 0.0, alpha: 0.3).CGColor
    view.layer.borderWidth = 0.5
}


// MARK: DEBUG BORDER
#if DEBUG // Target -> Other Swift Flags --> -DDEBUG
    
    func DEBUG_BORDER_COLOR(view:UIView) {
        
        view.layer.borderColor = UIColor(white: 0.0, alpha: 0.3).CGColor
        view.layer.borderWidth = 0.6
    }
    
    func DEBUG_BORDER_COLOR_L(view:UIView, thickness:CGFloat) {
        
        view.layer.borderColor = UIColor(white: 0.0, alpha: 0.3).CGColor
        view.layer.borderWidth = thickness
    }
    
#else
    
    func DEBUG_BORDER_COLOR(view:UIView) {
        
        view.layer.borderColor = UIColor.clearColor().CGColor
        view.layer.borderWidth = 0.3
    }
    
    func DEBUG_BORDER_COLOR_L(view:UIView, thickness:CGFloat) {
        
        view.layer.borderColor = UIColor.clearColor().CGColor
        view.layer.borderWidth = thickness
    }
    
#endif


// MARK:- PRINT CONSTANTS
func PRINT_RECT(frame:CGRect) {
    print("Frame = \(frame)")
}

func PRINT_SIZE(size:CGSize) {
    print("Size = \(size)")
}



/*
 if #available(iOS 9.0, *) {
 // use UIStackView
 } else {
 // show sad face emoji
 }
 */

// MARK:- iOS VERSION CONSTANTS

func SYSTEM_VERSION_EQUAL_TO(version: String) -> Bool {
    return UIDevice.currentDevice().systemVersion.compare(version,
                                                          options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedSame
}

func SYSTEM_VERSION_GREATER_THAN(version: String) -> Bool {
    return UIDevice.currentDevice().systemVersion.compare(version,
                                                          options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedDescending
}

func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return UIDevice.currentDevice().systemVersion.compare(version,
                                                          options: NSStringCompareOptions.NumericSearch) != NSComparisonResult.OrderedAscending
}

func SYSTEM_VERSION_LESS_THAN(version: String) -> Bool {
    return UIDevice.currentDevice().systemVersion.compare(version,
                                                          options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedAscending
}

func SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return UIDevice.currentDevice().systemVersion.compare(version,
                                                          options: NSStringCompareOptions.NumericSearch) != NSComparisonResult.OrderedDescending
}



