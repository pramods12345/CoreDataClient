//
//  CoreDataStack.swift
//  CoreDataStack
//
//  Created by Prasad Pai on 1/29/16.
//  Copyright © 2016 YMedia Labs. All rights reserved.
//

import CoreData

/**
 _CoreDataBlock_ corresponds to the completion handler's data block which will be used throughout the utility functions provided in the framework. The variables being passed inside it are of data types of _Bool_ (to indicate success/failure in operations) and _AnyObject?_ (at present, passes only _NSError_ in cases where operation is failure).
*/
public typealias CoreDataBlock = (_ errorObject: NSError?) -> ()

/**
  _CoreDataStackConfiguration_ is the structure based datatype for holding the configuration values like SQLlite, data model filenames etc of _CoreDataStack_. 
*/
public struct CoreDataStackConfiguration {
    
    // MARK: - Properties
    /// The name you would like to give for your Sqllite database storage.
    public var sqlFileName: String?
    
    /// The name of your Core Data Schematic file (.xcdatamodeld extension)
    public var dataModelName: String?
    
    /// If you are migrating your Core Data Model to new Model. Default value is true.
    public var migration: Bool = true
    
    /// The merge policy to be followed while saving changes in Core Data. Default value is NSErrorMergePolicy
    public var mergePolicyType: AnyObject = NSErrorMergePolicy
    
    // MARK: - Methods
    /// Initializer
    public init() {
        
    }
    
    /// Returns the default set of configurations of _CoreDataStack_
    public static func defaultConfiguration() -> CoreDataStackConfiguration {
        var manager = CoreDataStackConfiguration()
        manager.sqlFileName = "DataBase"
        
        return manager
    }
    
}

/**
 Core Data Stack which is written in Swift helps you to reduce the boiler plate code involved in creating the core data stack. Besides, it provides some functions in data fetching, deleting data records and data saving. Core Data Stack doesn't intend to help you in parsing or storing the data.
*/
open class CoreDataStack {
    
    // MARK: - Properties
    // Static properties
    fileprivate static var managerObject: CoreDataStack?
    
    /// Property holding the configuration values like SQLlite, data model filenames etc of _CoreDataStack_.
    open static var configuration: CoreDataStackConfiguration = CoreDataStackConfiguration.defaultConfiguration()
    
    
    // Private properties
    open var backgroundContext: NSManagedObjectContext?
    
    // Public properties
    /// To get persistent store coordinator instance being used in _CoreDataStack_.
    open var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    /// Use MainContext for operations related to fetching and displaying of data from Core Data.
    open var mainContext: NSManagedObjectContext?
    
    open var storeUrl : URL?
    {
        var fileURL : URL?
        if let fileName = CoreDataStack.configuration.sqlFileName
        {
            let pathComponent = [ NSHomeDirectory(), "Documents", fileName + ".sqlite" ]
            
            let pathString = NSString.path(withComponents: pathComponent)
            
             fileURL = URL(fileURLWithPath: pathString)
        }
        return fileURL
    }
    // MARK: - Methods
    /// Initializer
    fileprivate init() {
        
    }
    
    /// Core Data Stack follows Singleton pattern.
    ///
    /// Hence, for any function/variable to be called inside the Core Data Stack, the in-built shared instance of _CoreDataStack_ has to be made use of. To obtain the shared instance, make use of this class method.
    open class func sharedInstance() -> CoreDataStack {
        if managerObject == nil {
            managerObject = CoreDataStack()
            managerObject?.setup()
        }
        
        return managerObject!
    }
    
    /// Use WriteContext for operations related to storing data in Core Data.
    open func writeContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        if let parentContext = CoreDataStack.sharedInstance().mainContext {
            context.parent = parentContext
        }
        else if let parentContext = CoreDataStack.sharedInstance().backgroundContext {
            context.parent = parentContext
        }
        else {
            context.persistentStoreCoordinator = CoreDataStack.sharedInstance().persistentStoreCoordinator
        }
        context.mergePolicy = CoreDataStack.configuration.mergePolicyType
        
        return context
    }
    
    // MARK: - Private Methods
    fileprivate func setup() {
        if let dataModelName = CoreDataStack.configuration.dataModelName, let pathURL = Bundle.main.url(forResource: dataModelName, withExtension: "momd") {
            if let objectModel = NSManagedObjectModel(contentsOf: pathURL) {
                persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
                
                let options = [
                    NSMigratePersistentStoresAutomaticallyOption    :   CoreDataStack.configuration.migration,
                    NSInferMappingModelAutomaticallyOption          :   true
                ]
                
                // If there is no sqlite file to store, we will store objects in memory
                if let fileName = CoreDataStack.configuration.sqlFileName {
                    let pathComponent = [ NSHomeDirectory(), "Documents", fileName + ".sqlite" ]
                    
                    let pathString = NSString.path(withComponents: pathComponent)
                    
                    let fileURL = URL(fileURLWithPath: pathString)
                    
                    try! persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: fileURL, options: options)
                }
                else {
                    try! persistentStoreCoordinator?.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: options)
                }
                
                backgroundContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
                backgroundContext?.persistentStoreCoordinator = persistentStoreCoordinator
                
                mainContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
                mainContext?.parent = backgroundContext
            }
        }
    }
}
