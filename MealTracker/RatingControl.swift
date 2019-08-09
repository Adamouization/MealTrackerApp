//
//  RatingControl.swift
//  MealTracker
//
//  Created by Adam Jaamour on 08/08/2019.
//  Copyright © 2019 Adam Jaamour. All rights reserved.
//

import UIKit

class RatingControl: UIStackView {
    
    //MARK: Properties
    
    private var ratingButtons = [UIButton]() // Only accessible inside RatingControl class.
    var rating = 0

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
        // Create 5 buttons.
        for _ in 0..<5 {
            // Create a single button.
            let button = UIButton()
            button.backgroundColor = UIColor.red
            
            // Add constraints.
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
            button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
            
            // Setup the button action.
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add the button to the stack.
            addArrangedSubview(button)
            
            // Add the new button to the rating button array
            ratingButtons.append(button)
        }
    }
    
}
