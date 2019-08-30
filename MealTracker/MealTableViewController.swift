//
//  MealTableViewController.swift
//  MealTracker
//
//  Created by Adam Jaamour on 29/08/2019.
//  Copyright © 2019 Adam Jaamour. All rights reserved.
//

import UIKit
import os.log

class MealTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var meals = [Meal]()

    override func viewDidLoad() {
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved meals, otherwise load sample data.
        if let savedMeals = loadMeals() {
            meals += savedMeals
        } else {
            // Load the sample data.
            loadSampleMeals()
        }
        
        super.viewDidLoad()
    }

    
    // MARK: - Table view data source

    /// Makes the table view show 1 section.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /// Make the number of rows equal to the umber of meals.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        
        // Request a cell from the table views
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let meal = meals[indexPath.row]
        
        // Use the meal object to configure the cell.
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    /// Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the meal from the array and save it whenever a meal is deleted.
            meals.remove(at: indexPath.row)
            saveMeals()
            // Delete the row from the data source.
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    //MARK: - Navigation

    /// In a storyboard-based application, you will often want to do a little preparation before navigation.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
            // User is adding a new meal
            case "AddItem":
                os_log("Adding a new meal.", log: OSLog.default, type: .debug)
            
            // User is editing a meal, so need to display meal data in meal detail scene.
            case "ShowDetail":
                
                // Get the destination view controller.
                guard let mealDetailViewController = segue.destination as? MealViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                
                // Get the meal cell selected by the user.
                guard let selectedMealCell = sender as? MealTableViewCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
                
                // Get the index path of the selected cell.
                guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                
                // Look up the meal object for that path and pass it to the destination view controller once index path is retrieved.
                let selectedMeal = meals[indexPath.row]
                mealDetailViewController.meal = selectedMeal
            
            // Default case in case segue identifier is nil.
            default:
                fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
    //MARK: Actions
    
    /// Updates list and saves the meals array whenever a new one is added or an existing one is updated.
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            
            // Checks whether a row in the table view is selected to update an existing meal.
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                meals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            
                // No selected row in the table view means that user tapped the Add button to get to the meal detail scene.
            else {
                // Add a new meal by computing the location in the table view where the new table view cell representing
                // the new meal will be inserted, and stores it in a local constant called newIndexPath
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                
                // Adds the new meal to the existing list of meals in the data model.
                meals.append(meal)
                
                // Animates the addition of a new row to the table view.
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            // Save the meals.
            saveMeals()
        }
    }
    
    
    //MARK: Private Methods
    
    /// Helper method to load sample data into the app.
    private func loadSampleMeals() {
        // Load the 3 sample images meals.
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        
        // Create 3 meal objects.
        guard let meal1 = Meal(name: "Kobe Beef Box", photo: photo1, rating: 5) else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let meal2 = Meal(name: "Caviar & Ursin", photo: photo2, rating: 3) else {
            fatalError("Unable to instantiate meal2")
        }
        
        guard let meal3 = Meal(name: "Whale Nigiri Sushi", photo: photo3, rating: 4) else {
            fatalError("Unable to instantiate meal3")
        }
        
        // Add the meals to the array.
        meals += [meal1, meal2, meal3]
    }
    
    /// Save and load the meal list whenever a user adds, edits, or removes a meal.
    private func saveMeals() {
        // Attempts to archive the meals array to a specific location, and returns true if it’s successful.
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        
        // Log success/failure to save the data.
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    /// Loads meals. Has a return type of an optional array of Meal objects (might return an array of Meal objects or (nil).
    private func loadMeals() -> [Meal]? {
        // Attempts to unarchive the object stored at the path Meal.ArchiveURL.path and downcast that object to an array of Meal objects.
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }

}
