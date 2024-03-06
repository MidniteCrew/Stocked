//
//  DraggingTextViews.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-02-19.
//

import UIKit

extension ViewController{
    
    public func setupGestureRecognizers(for textView: UITextView) {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        textView.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc public func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        guard let textView = gesture.view as? UITextView else { return }
        let locationInView = gesture.location(in: self.scrollView)
        let locationInSuperView = gesture.location(in: self.view)
        
        
        switch gesture.state {
        case .began:
            self.view.bringSubviewToFront(textView)
            updateScrollViewForDragging(textView, location: locationInView)
            startScrollTimer()
        case .changed:
            let newY = locationInSuperView.y - (textView.frame.size.height / 2)
            textView.frame.origin.y = newY
            reorderTextViewsIfNeeded(textView)
        case .ended, .cancelled:
            updateScrollViewForEndDragging(textView, location: locationInView)
            stopScrollTimer()
            updateTextViewPosition(textView)
            
            // Update the position of the indicator
            if let indicator = selectionIndicators[textView] {
                updateIndicatorPosition(indicator, relativeTo: textView)
            }
        default:
            break
        }
    }
    
    public func updateTextViewPosition(_ textView: UITextView) {
        let sortedTextViews = textViews.sorted { $0.frame.origin.y < $1.frame.origin.y }
        var newYOffset: CGFloat = 175
        for tv in sortedTextViews {
            UIView.animate(withDuration: 0.3) {
                tv.frame.origin.y = newYOffset
            }
            newYOffset += tv.frame.height + spacing
        }
        // Update the main textViews array with the new sorted order
        self.textViews = sortedTextViews
        updateScrollViewContentSize()
    }
    
    public func reorderTextViewsIfNeeded(_ draggedTextView: UITextView) {
        var yOffset: CGFloat = 175 // Starting y-offset
        var newOrder = [UITextView]()
        
        // Sort textViews based on their current y position
        let sortedTextViews = textViews.sorted { $0.frame.origin.y < $1.frame.origin.y }
        
        // Reassign positions based on the sorted order
        for textView in sortedTextViews {
            if textView != draggedTextView {
                UIView.animate(withDuration: 0.3) {
                    textView.frame.origin.y = yOffset
                }
            }
            yOffset += textView.frame.height + spacing
            newOrder.append(textView)
            
            // Update the position of the selection indicator
            if let indicator = selectionIndicators[textView] {
                updateIndicatorPosition(indicator, relativeTo: textView)
            }
        }
        
        // Update the main textViews array with the new order
        self.textViews = newOrder
        updateScrollViewContentSize()
    }
    
    public func updateFramesOfTextViews() {
        var yOffset: CGFloat = 175
        
        for textView in self.textViews {
            UIView.animate(withDuration: 0.3) {
                textView.frame.origin.y = yOffset
                yOffset += textView.frame.height + self.spacing
            }
        }
        
        updateScrollViewContentSize()
    }
    
    public func updateScrollViewForDragging(_ textView: UITextView, location: CGPoint) {
        // Optionally, you can add any visual changes or animations when dragging starts
        UIView.animate(withDuration: 0.3) {
            textView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            textView.alpha = 0.7 // Makes the textView slightly transparent
        }
    }
    
    public func updateScrollViewForEndDragging(_ textView: UITextView, location: CGPoint) {
        // Reset visual changes made at the beginning of dragging
        UIView.animate(withDuration: 0.3) {
            textView.transform = CGAffineTransform.identity
            textView.alpha = 1.0
        }
        
        // Snap the textView back into its calculated position in the array
        if let index = self.textViews.firstIndex(of: textView) {
            let newY = calculateYPositionFor(index: index)
            textView.frame.origin.y = newY
        }
        
        // Update the scroll view's content size in case the order of views changed
        updateScrollViewContentSize()
    }
    
    public func calculateYPositionFor(index: Int) -> CGFloat {
        var yOffset: CGFloat = 175
        for i in 0..<index {
            yOffset += self.textViews[i].frame.size.height + spacing
        }
        return yOffset
    }
    
    
    public func reorderTextViews() {
        var yOffset: CGFloat = 175
        
        for textView in textViews {
            UIView.animate(withDuration: 0.2) {
                textView.frame.origin.y = yOffset
                if let indicator = self.selectionIndicators[textView] {
                    self.updateIndicatorPosition(indicator, relativeTo: textView)
                }
            }
            yOffset += textView.frame.height + spacing
        }
    }
    
}
