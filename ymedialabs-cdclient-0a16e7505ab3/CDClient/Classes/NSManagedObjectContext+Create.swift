//
//  NSManagedObjectContext+Save.swift
//  CoreDataStack
//
//  Created by Prasad Pai on 1/29/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import CoreData

public extension NSManagedObjectContext
{
    // MARK: - Data Saving Method
    /**
     To save the changes made in the context.
     */
    public func findFirstAndCreate<T: NSManagedObject>(entityName EntityName : String, attributeName : String? = nil, attributeValue : Any? = nil) -> T
    {
        if let attributeName = attributeName, let attributeValue = attributeValue
        {
           if let firstObject = self.fetchFirstObjectFromEntityWithEntityName(EntityName, attributeName: attributeName, attributeValue: attributeValue as AnyObject?)
           {
                return firstObject as! T
           }
           else
           {
                return self.createNewObjectWith(entityName: EntityName)
           }
            
        }
        else
        {
            return self.createNewObjectWith(entityName: EntityName)
        }
    }
    
    public func createNewObjectWith<T: NSManagedObject>(entityName EntityName : String) -> T
    {
        return NSManagedObject.init(entity:(NSEntityDescription.entity(forEntityName: EntityName, in: self))!, insertInto: self) as! T
    }

}
