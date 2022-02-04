//
//  NSManagedObjectContext+Delete.swift
//  CoreDataStack
//
//  Created by Prasad Pai on 1/29/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import CoreData

public extension NSManagedObjectContext {
    
    // MARK: - Data Deleting Methods
/**
    To delete all the records in a particular entity followed by saving the changes in Core Data context.
*/
    public func deleteEntityDataAndSaveWithEntityName(_ entityName: String, withCallback callback: CoreDataBlock?)
    {
        let isSuccess = self.deleteEntityDataWithEntityName(entityName)
        guard isSuccess else
        {
            callback?(NSError(domain: "Unable to delete the data", code: 0123, userInfo: [NSLocalizedDescriptionKey: "Unable",NSLocalizedFailureReasonErrorKey:"Unable to delete the data"]))
            return
        }
        
        self.saveAllWithCallback { (errorObject) in
            callback?(errorObject)

        }
    }
    
/**
    To delete all the records in a particular entity.
*/
    public func deleteEntityDataWithEntityName(_ entityName: String) -> Bool {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        var isSuccess = true
        
        // Commented by Varun - Batch delete is returning error "NSMergeConflict" and doesn't save properly. 
        
//        if #available(iOS 9.0, *) {
//            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//            do {
//                try self.persistentStoreCoordinator?.executeRequest(deleteRequest, withContext: self)
//            }
//            catch {
//                isSuccess = false
//            }
//            
//        } else {
            do {
                let allEntries = try self.fetch(fetchRequest)
                for counter in 0 ..< allEntries.count
                {
                    let entry = allEntries[counter]
                    self.delete(entry as! NSManagedObject)
                }
            }
            catch {
                isSuccess = false
            }
            
//        }
        return isSuccess
    }
 
/**
     To delete the records obtained through filtering by certain attribute specified in attributeName parameter.
*/
    public func deleteRecordsInEntityWithEntityName(_ entityName: String, attributeName: String, attributeValue: AnyObject) -> Bool {
        if let predicate = getPredicateWithAttributeName(attributeName, attributeValue: attributeValue) {
            let isSuccess = self.deleteRecordsInEntityWithEntityName(entityName, predicate: predicate)
            return isSuccess
        }
        return false
    }
    
/**
     To delete the records obtained through filtering by certain attribute specified in attributeName parameter followed by saving the changes in Core Data context.
*/
    public func deleteRecordsAndSaveInEntityWithEntityName(_ entityName: String, attributeName: String, attributeValue: AnyObject, withCallback callback: CoreDataBlock?) {
        let isSuccess = self.deleteRecordsInEntityWithEntityName(entityName, attributeName: attributeName, attributeValue: attributeValue)
        guard isSuccess else {
                callback?(NSError(domain: "Unable to delete the data", code: 0123, userInfo: [NSLocalizedDescriptionKey: "Unable",NSLocalizedFailureReasonErrorKey:"Unable to delete the data"]))
                return
            }
            
            self.saveAllWithCallback { (errorObject) in
                callback?(errorObject)
                
            }
    }
    
/**
     To delete the records obtained through filtering by certain predicate string followed by saving the changes in Core Data context. Use this method when several attributes are to be filtered through.
*/
    public func deleteRecordsAndSaveInEntityWithEntityName(_ entityName: String, predicateString: String, withCallback callback: CoreDataBlock?) {
        let isSuccess = self.deleteRecordsInEntityWithEntityName(entityName, predicateString: predicateString)
        guard isSuccess else {
                callback?(NSError(domain: "Unable to delete the data", code: 0123, userInfo: [NSLocalizedDescriptionKey: "Unable",NSLocalizedFailureReasonErrorKey:"Unable to delete the data"]))
                return
            }
            
            self.saveAllWithCallback { (errorObject) in
                callback?(errorObject)
                
            }
    }
    
/**
     To delete the records obtained through filtering by certain predicate string. Use this method when several attributes are to be filtered through.
*/
    public func deleteRecordsInEntityWithEntityName(_ entityName: String, predicateString: String) -> Bool {
        let predicate = NSPredicate(format: entityName)
        let isSuccess = self.deleteRecordsInEntityWithEntityName(entityName, predicate: predicate)
        return isSuccess
    }
    
/**
     To delete the set of records.
*/
    public func deleteTheSet(_ oldSet: NSSet) {
        let oldObjectsArray = oldSet.allObjects
        
        //for var counter = oldObjectsArray.count - 1; counter >= 0; counter--
        for counter in (0..<oldObjectsArray.count).reversed()
        {
            let oldObject = oldObjectsArray[counter] as! NSManagedObject
            self.delete(oldObject)
        }
    }
    
/**
     To delete the set of records followed by saving the changes in Core Data context.
*/
    public func deleteAndSaveTheSet(_ oldSet: NSSet, withCallback callback: CoreDataBlock?) {
        self.deleteTheSet(oldSet)
        
        self.saveAllWithCallback { (errorObject) in
            callback?(errorObject)
        }
    }
    
    // MARK: Internal methods
    public func getPredicateWithAttributeName(_ attributeName: String, attributeValue: AnyObject) -> NSPredicate? {
        var predicate: NSPredicate?
        switch attributeValue {
        case let str as String:
            predicate = NSPredicate(format: "%K == %@", attributeName, str)
        case let number as Int:
            predicate = NSPredicate(format: "%K == %d", attributeName, number)
        case let number as Int16:
            predicate = NSPredicate(format: "%K == %d", attributeName, number)
        case let number as Int32:
            predicate = NSPredicate(format: "%K == %d", attributeName, number)
        case let number as Int64:
            predicate = NSPredicate(format: "%K == %d", attributeName, number)
        case let number as Float:
            predicate = NSPredicate(format: "%K == %f", attributeName, number)
        case let number as Double:
            predicate = NSPredicate(format: "%K == %lf", attributeName, number)
        case let boolValue as Bool:
            predicate = NSPredicate(format: "%K == %@", attributeName, boolValue as CVarArg)
        case let date as Date:
            predicate = NSPredicate(format: "%K == %@", attributeName, date as CVarArg)
        default:
            predicate = nil
        }
        return predicate
    }
    
    // MARK: - Private methods
    fileprivate func deleteRecordsInEntityWithEntityName(_ entityName: String, predicate: NSPredicate) -> Bool {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        var isSuccess = true
        do {
            let allEntries = try self.fetch(fetchRequest)
            for counter in 0 ..< allEntries.count
            {
                let entry = allEntries[counter]
                self.delete(entry as! NSManagedObject)
            }
        }
        catch {
            isSuccess = false
        }
        return isSuccess
    }
}
