//
//  MealViewController.swift
//  MealTracker
//
//  Created by Adam Jaamour on 06/08/2019.
//  Copyright © 2019 Adam Jaamour. All rights reserved.
//

import UIKit
import os.log

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // This value is either passed by `MealTableViewController` in `prepare(for:sender:)` or constructed as part of adding a new meal.
    var meal: Meal?
    
    /// UIViewController method called when the view controller’s content view is created and loaded from a storyboard.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        // Set up views if user is editing an already existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text   = meal.name
            imageView.image = meal.photo
            ratingControl.rating = meal.rating
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        updateSaveButtonState()
    }
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    /// Disable the Save button while the user is editing the text field.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Check if the text field has text in it to enable the Save button if it does.
        updateSaveButtonState()
        
        // Sets the title of the scene to that text.
        navigationItem.title = textField.text
    }
    
    
    //MARK: UIImagePickerControllerDelegate
    
    /// Gets called when a user taps the image picker’s Cancel button.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    /// Gets called when a user selects a photo.
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set imageView to display the selected image.
        imageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Navigation
    
    /// Dismisses the modal scene and animates the transition back to the previous scene in 2 different ways depending on the style of presentation (modal or push presentation).
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Creates a Boolean value that indicates whether the view controller that presented this scene is of type UINavigationController
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            // The app does not store any data when the meal detail scene is dismissed,
            //and neither the prepare(for:sender:) method nor the unwind action method are called.
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    /// This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed, verifies that the sender is a button.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? "" // return an empty string if nameTextField.text is nil
        let photo = imageView.image
        let rating = ratingControl.rating
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        meal = Meal(name: name, photo: photo, rating: rating)
    }
    
    
    //MARK: Actions
    
    @IBAction func selectImageFromPhotosLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard in case user clicks image placeholder while typing.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        // Asks ViewController to present the view controller defined by imagePickerController.
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    //MARK: Private Methods
    
    /// Helper method to disable the Save button if the text field is empty.
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
}
