//
//  ViewController.swift
//  HitList
//
//  Created by Abhijeet Mishra on 03/02/17.
//  Copyright © 2017 Abhijeet Mishra. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {
    
    var people = [NSManagedObject]()
    
    var names = [String]()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "\"List\""
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Person")
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            people = results as! [NSManagedObject]
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let person = people[indexPath.row]
        cell!.textLabel!.text = person.value(forKey: "name") as? String
        return cell!
    }
    
    
    func saveName(name:String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
       let person = NSEntityDescription.insertNewObject(forEntityName: "Person", into: managedObjectContext);
    
        person.setValue(name, forKey: "name")
        
        do {
            try managedObjectContext.save()
            people.append(person)
        }
        catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func addName(_ sender: UIBarButtonItem) {
    
        let alert = UIAlertController(title: "New Name", message:"Add a new name", preferredStyle:.alert)
        
        let saveAction = UIAlertAction(title: "Save", style:.default, handler:{
            (action:UIAlertAction) -> Void in
            let textField = alert.textFields!.first
            self.names.append(textField!.text!)
            self.saveName(name: textField!.text!)
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title:"Cancel", style:.default, handler:{
            (action: UIAlertAction) -> Void in
        })
        
       alert.addTextField { (textfield) in
        
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true) { 
            
        }
    }
}
