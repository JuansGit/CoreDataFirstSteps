//
//  AppDelegate.swift
//  CoreDataFirstSteps
//
//  Created by Consultant on 3/21/19.
//  Copyright © 2019 JuanVitela. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        print("App has started")
        
        let moc = persistentContainer.viewContext
//        let notebookObject = Notebook(context: moc)
//        notebookObject.title = "Understanding the universe"
//        notebookObject.createdAt = Date() as Date?
//
//        for index in 1 ... 10 {
//            let noteObject = Note(context: moc)
//            noteObject.content = "Universe \(index)"
//            noteObject.title = "Number \(index) universe"
//            noteObject.createdAt = Date()
//
//            notebookObject.addToNote(noteObject)
//        }
//
//        saveContext()


        let notebookRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        notebookRequest.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        notebookRequest.sortDescriptors = [sortDescriptor]
        
//        let keyPath = "title"
//        let searchString = "with"
//
//        let notebookPredicate = NSPredicate(format: "%K CONTAINS %@", keyPath, searchString)
//        notebookRequest.predicate = notebookPredicate
        
        let keyPath = "note.content"
        let searchString = "stuff 11"

        let complexPredicate = NSPredicate(format: "ANY %K CONTAINS %@", keyPath, searchString)
        notebookRequest.predicate = complexPredicate
        
        var notebookArray = [Notebook]()
        var notebookCount = 0
        
        do {
            notebookArray = try moc.fetch(notebookRequest)
            notebookCount = try moc.count(for: notebookRequest)
            print("The number of rows in this table is \(notebookCount)")
        } catch {
            print(error.localizedDescription)
        }
        
        
        for notebook in notebookArray{
            print("This is the notebook with title \(notebook.title!) and it was created at \(notebook.createdAt!)")
            displayNotes(notebook: notebook)
        }
        

        return true
    }
    
    func displayNotes(notebook : Notebook){
        if let notes = notebook.note as? Set<Note>{
            let sortedNotesArray = notes.sorted { (noteA: Note, noteB: Note) -> Bool in
                return noteA.createdAt!.compare(noteB.createdAt!) == ComparisonResult.orderedAscending
            }
            for note  in sortedNotesArray{
                print(note.title!)
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveContext()
    }
    
    
    //MARK: Core Data Stack
    
    lazy var persistentContainer : NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FirstStepsDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription:NSPersistentStoreDescription, error : Error?) in
            if let error = error as NSError?{
                print(error.localizedDescription)
                
            }
        })
        return container
        
        }()

    func saveContext(){
        let context = persistentContainer.viewContext
        if context.hasChanges{
            do{
                try  context.save()
            }catch{
                print(error.localizedDescription)
            }
           
        }
    }
}

