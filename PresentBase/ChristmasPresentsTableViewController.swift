//
//  ChristmasPresentsTableViewController.swift
//  PresentBase
//
//  Created by Charles Martin Reed on 8/16/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import CoreData

class ChristmasPresentsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    var myGifts = [["name": "Best Friend", "image": "1", "item": "3DS XL"],
//                   ["name": "Mom", "image": "2", "item": "Oculus Go"],
//                   ["name": "Dad", "image": "3", "item": "Crockpot"],
//                   ["name": "Sister", "image": "4", "item": "Raspberry Pi"]]
    
    //create an array of Present objects and directly initialize it
    var presents = [Present]()
    
    //creating a managed object context for Core Data
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        //adding our sleigh icon, using UIImageView and adding it to the navigation item's titleView
        let iconImageView = UIImageView(image: UIImage(named: "sleighIcon"))
        iconImageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = iconImageView
        
        //return the managed Object Context for use throughout our class
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        loadData()
    }
    
    //MARK: - loading our data from the Core Data model
    func loadData() {
        //create a fetch request
        let presentRequest: NSFetchRequest<Present> = Present.fetchRequest()
        
        do {
            presents = try managedObjectContext.fetch(presentRequest)
            self.tableView.reloadData()
        } catch {
            print("Could not load data from database: \(error.localizedDescription)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return presents.count
    }
    
    //fixing our height issue
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PresentsTableViewCell
        
        let presentItem = presents[indexPath.row]
        
        if let presentImage = UIImage(data: presentItem.image as! Data) {
            cell.backgroundImageView.image = presentImage
        }
        
        
        cell.nameLabel.text = presentItem.person
        cell.itemLabel.text = presentItem.presentName
        
        return cell
    }
 
    @IBAction func addPresent(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true) {
                self.createPresentItem(with: image)
            }
        }
        
        
    }
    
    func createPresentItem (with image: UIImage) {
        
        //present alert view on the table view controller screen
        //present class created by Xcode when using Core Data
        let presentItem = Present(context: managedObjectContext)
        presentItem.image = NSData(data: UIImageJPEGRepresentation(image, 0.3)!) as Data
        
        let inputAlert = UIAlertController(title: "New Present", message: "Enter a person and a present", preferredStyle: .alert)
        
        inputAlert.addTextField { (textField: UITextField) in
            textField.placeholder = "Person"
        }
        inputAlert.addTextField { (textField: UITextField) in
            textField.placeholder = "Present"
        }
        
        inputAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action: UIAlertAction) in
            
            let personTextField = inputAlert.textFields?.first
            let presentTextField = inputAlert.textFields?.last
            
            //add the person and present info to our Core Data entity
            if personTextField?.text != "" && presentTextField?.text != "" {
                presentItem.person = personTextField?.text
                presentItem.presentName = presentTextField?.text
                
                //try saving the data to the Core Data model
                do {
                    try self.managedObjectContext.save()
                    self.loadData()
                }
                catch {
                    print("Could not save data \(error.localizedDescription)")
                }
            }
        }))
        
        inputAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(inputAlert, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
   

}
