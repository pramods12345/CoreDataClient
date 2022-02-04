//
//  NSManagedObjectContext+Save.swift
//  CoreDataStack
//
//  Created by Prasad Pai on 1/29/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import CoreData

public extension NSManagedObjectContext {
    
    // MARK: - Data Saving Method
/**
    To save the changes made in the context.
*/
    public func saveAllWithCallback(_ completion: CoreDataBlock?) {
        do
        {
            if self.hasChanges
            {
                try self.save()
                if let parentContext = self.parent
                {
//                    parentContext.performBlock({ 
                        parentContext.saveAllWithCallback(completion)
                  //  })
                }
                else
                {
                    completion?(nil)
                }
            }
            else
            {
                completion?(nil)
            }
        }
        catch
        {
            let nserror = error as NSError
            completion?(nserror)
        }
    }
}
