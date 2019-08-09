//
//  RatingControl.swift
//  MealTracker
//
//  Created by Adam Jaamour on 08/08/2019.
//  Copyright © 2019 Adam Jaamour. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    //MARK: Properties
    
    private var ratingButtons = [UIButton]()  // Only accessible inside RatingControl class.
    var rating = 0
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {  // Called immediately after the property’s value is set.
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {  // Called immediately after the property’s value is set.
            setupButtons()
        }
    }

    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: Button Action
    
    @objc func ratingButtonTapped(button: UIButton) {
        print("Button pressed 👍")
    }
    
    //MARK: Private Methods
    
    private func setupButtons() {
        
        // Clear any existing buttons.
        for button in ratingButtons {
            removeArrangedSubview(button)  // Remove the button from the stack.
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()  // Remove all buttons from the rating button array.
        
        // Create 5 buttons.
        for _ in 0..<starCount {
            // Create a single button.
            let button = UIButton()
            button.backgroundColor = UIColor.red
            
            // Add constraints.
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Setup the button action.
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add the button to the stack.
            addArrangedSubview(button)
            
            // Add the new button to the rating button array.
            ratingButtons.append(button)
        }
    }
    
}
