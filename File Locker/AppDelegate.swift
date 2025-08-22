//
//  AppDelegate.swift
//  File Locker
//
//  Created by MAC_RD on 2025/2/5.
//
//  Copyright © 2025 MAC_RD. All rights reserved.
///1.0.1:
///************① 增加wifi传输功能
///************② pdf阅读
///************③ website阅读
///************④ 支持gcp格式文件阅读
///



import UIKit
let kDocumentsFolder = "\(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!.path)/Documents"
let kHEIGHT : CGFloat =  UIScreen.main.bounds.size.height
let kWIDTH : CGFloat = UIScreen.main.bounds.size.width
let SafeAreaTopHeight : CGFloat = ((kHEIGHT >= 812.0) && UIDevice.current.model.isEqual("iPhone") ? 88 : 64)
let SafeAreaBottomHeight : CGFloat = ((kHEIGHT >= 812.0) && UIDevice.current.model.isEqual("iPhone") ? 30 : 0)

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        //let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentsPath = tempDirectory.path
        do {
            // Get files and their creation dates
            let filesWithDates = try fileManager.contentsOfDirectory(atPath: documentsPath).map { filename -> (String, Date) in
                let filePath = (documentsPath as NSString).appendingPathComponent(filename)
                let attributes = try fileManager.attributesOfItem(atPath: filePath)
                return (filename, attributes[.creationDate] as? Date ?? Date.distantPast)
            }
            
            // Sort files by creation date (newest first)
            let fileList = filesWithDates.sorted { $0.1 > $1.1 }.map { $0.0 }
            if (fileList != nil){
                for i in 0 ..< fileList.count {
                    if let pathExtension = (fileList[i] as? NSString)?.pathExtension.lowercased(){
                        if pathExtension.count > 0 ,((pathExtension != "gem") && (pathExtension != "gfx") && (pathExtension != "gcp")) {
                            if let fileName = (fileList[i] as? NSString)?.lastPathComponent {
                                var itemFilePath : String = documentsPath + "/" + fileName
                                try? fileManager.removeItem(atPath: itemFilePath)
                            }
                        }
                    }
                }
            }
            
        } catch {
            print("Error : \(error)")
        }
        // Override point for customization after application launch.
        return true
    }

}

