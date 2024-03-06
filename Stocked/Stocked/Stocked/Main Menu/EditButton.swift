//
//  EditButton.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-02-19.
//

import UIKit

// Add a property for the delete button
public let deleteButton = UIButton(type: .system)


extension ViewController{
    
    
    public func updateIndicatorPosition(_ indicator: UIButton, relativeTo textView: UITextView) {
        let indicatorSize: CGFloat = 20
        let indicatorMargin: CGFloat = 10
        let xPosition = textView.frame.minX - indicatorSize - indicatorMargin
        let yPosition = textView.frame.midY - indicatorSize / 2
        
        UIView.animate(withDuration: 0.2) {
            indicator.frame = CGRect(x: xPosition, y: yPosition, width: indicatorSize, height: indicatorSize)
        }
    }
    
    func updateTextViewsForEditingMode() {
        let indicatorSize: CGFloat = 20 // Size of the indicator
        let indicatorMargin: CGFloat = 10 // Margin from the textView
        
        for textView in textViews {
            let selectionIndicator: UIButton
            if let existingIndicator = selectionIndicators[textView] {
                selectionIndicator = existingIndicator
            } else {
                let xPosition = textView.frame.minX - indicatorSize - indicatorMargin
                let yPosition = textView.frame.midY - indicatorSize / 2
                
                selectionIndicator = UIButton(frame: CGRect(x: xPosition, y: yPosition, width: indicatorSize, height: indicatorSize))
                selectionIndicator.layer.cornerRadius = indicatorSize / 2 // Make it circular
                selectionIndicator.backgroundColor = .red // Set the color of the circle
                selectionIndicators[textView] = selectionIndicator
                scrollView.addSubview(selectionIndicator)
            }
            
            selectionIndicator.isHidden = !isEditingMode
        }
    }
    
    @objc func textViewTapped(_ gesture: UITapGestureRecognizer) {
        
        guard let textView = gesture.view as? UITextView else { return }
        
        if isEditingMode {
            //Haptic Feedback
            let feedbackGenerator = UISelectionFeedbackGenerator()
                feedbackGenerator.selectionChanged()
            
            // Editing mode is active, select the tapped text view
            selectTextView(textView)
        } else {
            // Regular mode, let the user edit the text view
            textView.becomeFirstResponder()
        }
    }
    
    func selectTextView(_ textView: UITextView) {
        if selectedTextViews.contains(textView) {
            selectedTextViews.remove(textView)
        } else {
            selectedTextViews.insert(textView)
        }
        
        // Update the visibility of the delete button based on whether any TextViews are selected
        deleteButton.isHidden = selectedTextViews.isEmpty
        
        // Update the selection indicator for the tapped text view
        updateSelectionIndicator(for: textView)
    }
    
    func updateSelectionIndicator(for textView: UITextView) {
        guard let indicator = selectionIndicators[textView] else { return }
        
        if selectedTextViews.contains(textView) {
            // Change the indicator to a green circle with a black checkmark when the text view is selected
            indicator.backgroundColor = UIColor.green
            if let checkmarkImage = UIImage(systemName: "checkmark.circle.fill") {
                indicator.setImage(checkmarkImage, for: .normal)
                indicator.tintColor = UIColor.black // Set the tint color to black for the checkmark
            }
        } else {
            // Set back to the default appearance (red circle) when the text view is not selected
            indicator.backgroundColor = .red // You can set the original color
            indicator.setImage(nil, for: .normal)
        }
    }
    
    
    public func setupDeleteButton() {
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteSelectedTextViews), for: .touchUpInside)
        Main_Menu.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            deleteButton.centerYAnchor.constraint(equalTo: AddButton.centerYAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: Main_Menu.leadingAnchor, constant: 20),
            deleteButton.widthAnchor.constraint(equalToConstant: 100),
            deleteButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        deleteButton.isHidden = true
        AddButton.isEnabled = true
        AddButton.isHidden = false
    }


    
    
}
