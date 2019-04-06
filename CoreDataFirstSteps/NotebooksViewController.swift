//
//  NotebooksViewController.swift
//  CoreDataFirstSteps
//
//  Created by Consultant on 3/27/19.
//  Copyright © 2019 JuanVitela. All rights reserved.
//

import UIKit
import CoreData

class NotebooksViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var notebooksTV: UITableView!
    var fetchedResultsController : NSFetchedResultsController<Notebook>!
    
    var moc: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.notebooksTV.delegate = self
        self.notebooksTV.dataSource = self
        setupFetchResultsController()
        
    }
    
    func setupFetchResultsController (){
        let notebookRequest:NSFetchRequest<Notebook> = Notebook.fetchRequest()
        let sortDescriptor : NSSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        notebookRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: notebookRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
}

extension NotebooksViewController: UITableViewDelegate , UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let notebookObject = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = notebookObject.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Change notebook", message: "Enter new title", preferredStyle: .alert)
        alertController.addTextField { (textfield: UITextField) in
            textfield.placeholder = "New notebook title"
        }
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
            
            let textfield = alertController.textFields?.first
            
            let noteBookObject = self.fetchedResultsController.object(at: indexPath)
            noteBookObject.title = textfield?.text
            
            try! self.moc.save()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let notebookObject = fetchedResultsController.object(at: indexPath)
            notebookObject.managedObjectContext?.delete(notebookObject)
            
            try! moc.save()
        }
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.notebooksTV.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .delete {
            self.notebooksTV.deleteRows(at: [indexPath!], with: .automatic)
        }else if type == .update {
            configureCell(indexPath: indexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.notebooksTV.endUpdates()
    }
    
    func configureCell(indexPath:IndexPath){
        let cell = self.notebooksTV.cellForRow(at: indexPath)
        let notebookObject = self.fetchedResultsController.object(at: indexPath)
        
        cell?.textLabel?.text = notebookObject.title
    }
    
}
