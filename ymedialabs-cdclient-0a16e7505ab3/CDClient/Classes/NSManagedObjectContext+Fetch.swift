//
//  NSManagedObjectContext+Fetch.swift
//  CoreDataStack
//
//  Created by Prasad Pai on 1/29/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import CoreData

private let fetchBatchSize = 100

/// Constant property of type _NSRange_ having both location and length of 0.
public let NSRangeZero = NSMakeRange(0, 0)

public extension NSManagedObjectContext {
    // MARK: Data Fetching Methods
/**
    To get data records. Specify entity name and ignore other parameter list to get all the records in an Entity type.
    
    Make use of optional attributeName parameter to obtain filtered records having the value specified in attributeValue parameter.
    
    Make use of sortDescriptor to sort the results. Use range to deploy batch size.
 */
    public func fetchFromEntityWithEntityName<T: NSManagedObject>(_ entityName: String, attributeName: String? = nil, attributeValue: AnyObject? = nil, sortDescriptorName: String? = nil, isSortAcending: Bool? = nil, range: NSRange = NSRangeZero) -> [T]? {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.fetchBatchSize = fetchBatchSize
        fetchRequest.fetchOffset = range.location
        fetchRequest.fetchLimit = range.length
        
        if let attributeName = attributeName, let attributeValue =  attributeValue,
            let predicate = self.getPredicateWithAttributeName(attributeName, attributeValue: attributeValue) {
                fetchRequest.predicate = predicate
        }
        
        if let sortDescriptorName = sortDescriptorName, let isSortAcending = isSortAcending {
            let sortDescriptor = NSSortDescriptor(key: sortDescriptorName, ascending: isSortAcending)
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        let result = try! self.fetch(fetchRequest)
        return result as? [T]
    }
    
/**
     To get the first data record created with data matching/comparision using only one attribute.
*/
    public func fetchFirstObjectFromEntityWithEntityName<T: NSManagedObject>(_ entityName: String, attributeName: String? = nil, attributeValue: AnyObject? = nil, sortDescriptorName: String? = nil, isSortAcending: Bool? = nil, range: NSRange = NSRangeZero) -> T? {
        let result = fetchFromEntityWithEntityName(entityName, attributeName: attributeName, attributeValue: attributeValue, sortDescriptorName: sortDescriptorName, isSortAcending: isSortAcending, range: range)
        
        if let result = result as! [T]? {
            return result.first
        }
        return nil
    }
    
/**
     To get data records created with predicate string. Use this method if data matching/comparision has to take place with more than one attribute.
*/
    public func fetchFromEntity<T: NSManagedObject>(entityName: String, predicateString: String? = nil, sortDescriptors: [NSSortDescriptor]? = nil, range: NSRange = NSRangeZero) -> [T]? {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.fetchBatchSize = fetchBatchSize
        fetchRequest.fetchOffset = range.location
        fetchRequest.fetchLimit = range.length
        
        if let predicateString = predicateString {
            fetchRequest.predicate = NSPredicate(format: predicateString)
        }
        
        if let sortDescriptors = sortDescriptors {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        let result = try! self.fetch(fetchRequest)
        return result as? [T]
    }
    
    
    public func fetchAllSortedBy<T: NSManagedObject>(entityName: String, attribute : String ,ascending : Bool = true, predicate : NSPredicate? = nil) -> [T]?
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName : entityName)
        if let predicate = predicate
        {
            fetchRequest.predicate = predicate
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: attribute, ascending: ascending)]
        let result = try! self.fetch(fetchRequest)
        return result as? [T]
    }
    
/**
     To get the first data record created with predicate string.
*/
    public func fetchFirstObjectFromEntity<T: NSManagedObject>(entityName: String, predicateString: String? = nil, sortDescriptors: [NSSortDescriptor]? = nil, range: NSRange = NSRangeZero) -> T? {
        let result = fetchFromEntity(entityName: entityName, predicateString: predicateString, sortDescriptors: sortDescriptors, range: range)
        
        if let result = result as! [T]? {
            return result.first
        }
        return nil
    }
    
/**
     To get data records with only required attributes type
*/
    public func fetchFromEntityWithEntityName(_ entityName: String, requiredAttributes propertiesToFetch: [String], predicateString: String? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [[String: AnyObject]]? {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.fetchBatchSize = fetchBatchSize
        
        if let predicateString = predicateString {
            fetchRequest.predicate = NSPredicate(format: predicateString)
        }
        
        if let sortDescriptors = sortDescriptors {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType;
        fetchRequest.propertiesToFetch = propertiesToFetch;
        
        let result = try! self.fetch(fetchRequest)
        return result as? [[String: AnyObject]]
    }
    
    public func fetchSectionFromEntityWithEntityName(_ entityName: String, sectionNameKeyPath: String? = nil, sortDescriptors: [NSSortDescriptor]? = nil,delegate : NSFetchedResultsControllerDelegate?) -> NSFetchedResultsController<NSFetchRequestResult>
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        fetchRequest.sortDescriptors = sortDescriptors
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil)
        
        frc.delegate = delegate
        
        return frc
    }
}
