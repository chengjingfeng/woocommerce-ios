#Storage

> This module encapsulates the local persistence layer, and provides an implementation of that persistence layer based on CoreData.  

## High level class diagram
![Storage high level class diagram](images/storage.png)

## Public interface
The Storage module exposes its functionality via the `StorageManagerType` protocol. 

This protocol declares getters to `StorageType` and methods to save or perform an operation on a `StorageType` 

## The CoreData stack
The default implementation of the `StorageManagerType` and `StorageType` protocols is based on CoreData.

 `StorageManagerType` is implemented by the `CoreDataManager` class. As the name implies, this class manages a CoreData stack, aggregating a `NSPersistentContainer` .

When clients of this class request a `StorageType`, `CoreDataManager` will return the a `NSManagedObjectContext`. 

When `CoreDataManager` is requested a  `viewContext`, it will provide  the persistent container’s `viewContext` . When it is requested a `newDerivedStorage` it will return a new child context with  a private dispatch queue.

## Model objects
This module also provides extensions to make the model objects declared in the `Networking` module coredata-compliant.  That is achieved by extending the model objects declared in `Networking` to make them extend `NSManagedObject` and provide `@NSManaged` properties and CoreData compliant accessors to some of those properties.
