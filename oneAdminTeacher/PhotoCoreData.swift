//
//  MessageCoreData.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/7/24.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotoCoreDataClass{
    
    //static var LockQueue = dispatch_queue_create("PhotoCoreDataClassLockQueue", nil)
    
    var appDelegate : AppDelegate
    var mocMain : NSManagedObjectContext!
    
    init(){
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        mocMain = appDelegate.managedObjectContext!
    }
    
    func Reset(){
        mocMain.reset()
    }
    
    //Core Data using
    func SaveCatchData(pd:PreviewData) {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "dsns=%@ and group=%@ and uid=%@", pd.Dsns, pd.Group, pd.Uid)
        
        if let fetchResults = (try? self.mocMain.executeFetchRequest(fetchRequest)) as? [NSManagedObject] {
            //update
            if fetchResults.count > 0 {
                
                let managedObject = fetchResults[0]
                
                managedObject.setValue(pd.Photo, forKey: "preview")
                
                do {
                    try self.mocMain.save()
                } catch _ {
                }
            }
            else{
                
                //insert
                let myEntityDescription = NSEntityDescription.entityForName("Photo", inManagedObjectContext: self.mocMain)
                
                let myObject = NSManagedObject(entity: myEntityDescription!, insertIntoManagedObjectContext: self.mocMain)
                
                myObject.setValue(pd.Dsns, forKey: "dsns")
                myObject.setValue(pd.Uid, forKey: "uid")
                myObject.setValue(pd.Group, forKey: "group")
                myObject.setValue(pd.Photo, forKey: "preview")
                myObject.setValue(nil, forKey: "detail")
                
                do {
                    try self.mocMain.save()
                } catch _ {
                }
                
                //println(error)

            }
        }
        
    }
    
    func UpdateCatchData(pd:PreviewData,detail:UIImage?) {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "dsns=%@ and group=%@ and uid=%@", pd.Dsns, pd.Group, pd.Uid)
        
        if let fetchResults = (try? self.mocMain.executeFetchRequest(fetchRequest)) as? [NSManagedObject] {
            if fetchResults.count != 0 {
                
                let managedObject = fetchResults[0]
                
                if let img = detail{
                    
                    managedObject.setValue(img, forKey: "detail")
                    
                    do {
                        try self.mocMain.save()
                    } catch _ {
                    }
                }
                
                
            }
        }
    }
    
    //Core Data using
    func LoadPreviewData(pd:PreviewData) -> UIImage?{
        
        var img : UIImage?
            
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "dsns=%@ and group=%@ and uid=%@", pd.Dsns, pd.Group, pd.Uid)
        
        if let fetchResults = (try? self.mocMain.executeFetchRequest(fetchRequest)) as? [NSManagedObject] {
            
            if fetchResults.count > 0{
                
                if let preview = fetchResults[0].valueForKey("preview") as? UIImage{
                    img = preview
                }
            }
        }
        
        return img
    }
    
    func LoadDetailData(pd:PreviewData) -> UIImage?{
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "dsns=%@ and group=%@ and uid=%@", pd.Dsns, pd.Group, pd.Uid)
        
        if let fetchResults = (try? self.mocMain.executeFetchRequest(fetchRequest)) as? [NSManagedObject] {
            
            if fetchResults.count == 1{
                
                if let detail = fetchResults[0].valueForKey("detail") as? UIImage{
                    return detail
                }
            }
        }
        
        return nil
    }
    
    //Core Data using
    func DeleteAll() {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        let results = (try! self.mocMain.executeFetchRequest(fetchRequest)) as! [NSManagedObject]
        
        for obj in results {
            self.mocMain.deleteObject(obj)
        }
        
        do {
            try self.mocMain.save()
        } catch _ {
        }
    }
    
    //Core Data using
    //    func DeletePhoto(pd:PreviewData) {
    //
    //        let fetchRequest = NSFetchRequest(entityName: "Photo")
    //        fetchRequest.predicate = NSPredicate(format: "dsns=%@ and uid=%@ and group=%@", pd.Dsns, pd.Uid, pd.Group)
    //
    //        let results = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as! [NSManagedObject]
    //
    //        for obj in results {
    //            managedObjectContext.deleteObject(obj)
    //        }
    //
    //        managedObjectContext.save(nil)
    //    }
    
    //    func GetCount() -> Int{
    //
    //        let fetchRequest = NSFetchRequest(entityName: "Photo")
    //
    //        let results = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as! [NSManagedObject]
    //
    //        return results.count
    //    }
}