//
//  MainMenuScrolling.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2024-02-19.
//

import UIKit

extension ViewController{
    
    public func scrollIfNeeded(for location: CGPoint) {
        let scrollViewBounds = scrollView.bounds
        let scrollViewHeight = scrollViewBounds.height
        let scrollThreshold: CGFloat = 50.0 // Distance from edge to start scrolling
        
        // Check if we need to scroll up
        if location.y < (scrollViewBounds.origin.y + scrollThreshold) {
            let contentOffset = max(scrollView.contentOffset.y - 10, 0)
            scrollView.setContentOffset(CGPoint(x: 0, y: contentOffset), animated: true)
        }
        // Check if we need to scroll down
        else if location.y > (scrollViewBounds.origin.y + scrollViewHeight - scrollThreshold) {
            let contentOffset = min(scrollView.contentOffset.y + 10, scrollView.contentSize.height - scrollViewHeight)
            scrollView.setContentOffset(CGPoint(x: 0, y: contentOffset), animated: true)
        }
    }
    
    public func startScrollTimer() {
        scrollTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleScroll), userInfo: nil, repeats: true)
    }
    
    public func stopScrollTimer() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
    
    @objc public func handleScroll() {
        guard let textView = scrollView.subviews.compactMap({ $0 as? UITextView }).first(where: { $0.isDragging }) else { return }
        let locationInSuperView = textView.center
        
        let scrollViewBounds = scrollView.bounds
        let scrollViewHeight = scrollViewBounds.height
        let scrollThreshold: CGFloat = 50.0
        let scrollAmount: CGFloat = 30.0
        
        if locationInSuperView.y < (scrollViewBounds.origin.y + scrollThreshold) {
            let newOffset = max(scrollView.contentOffset.y - scrollAmount, 0)
            scrollView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: false)
        } else if locationInSuperView.y > (scrollViewBounds.origin.y + scrollViewHeight - scrollThreshold) {
            let maxOffset = scrollView.contentSize.height - scrollViewHeight
            let newOffset = min(scrollView.contentOffset.y + scrollAmount, maxOffset)
            scrollView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: false)
        }
    }
    
    
    public func updateScrollViewContentSize() {
        guard let lastTextView = textViews.last else {
            // If there are no textViews, set content size to allow for minimal vertical bounce.
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.bounds.height + 1)
            return
        }
        
        // Calculate the bottom position of the last textView.
        let lastTextViewBottomPosition = lastTextView.frame.origin.y + lastTextView.frame.size.height
        
        // Calculate the bottom position of the Total Position Value label.
        let totalPositionValueLabelBottom = totalPositionValueLabel.frame.origin.y + totalPositionValueLabel.frame.size.height
        
        // Use the larger of the two values as the content height
        let contentHeight = max(lastTextViewBottomPosition, totalPositionValueLabelBottom)
        
        // Set the contentSize of the scrollView.
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
    }
    
    
    // Function to update layout for other components
    public func updateLayoutForExpandedOrContractedTextView(_ updatedTextView: UITextView) {
        var yOffset = CGFloat(100)
        var isUpdatedTextViewReached = false
        
        for textView in textViews {
            if textView == updatedTextView {
                isUpdatedTextViewReached = true
            }
            if isUpdatedTextViewReached {
                textView.frame.origin.y = yOffset
            }
            yOffset += textView.frame.height + spacing
        }
        
        updateScrollViewContentSize()
    }
    
    public func updateLayoutForTextViewChanges(_ updatedTextView: UITextView) {
        var yOffset = CGFloat(100)
        var updatePosition = false
        
        for textView in textViews {
            if textView == updatedTextView {
                updatePosition = true
            }
            if updatePosition {
                textView.frame.origin.y = yOffset
                if let indicator = selectionIndicators[textView] {
                    updateIndicatorPosition(indicator, relativeTo: textView)
                }
            }
            yOffset += textView.frame.height + spacing
        }
        
        updateScrollViewContentSize()
    }
    
    
    // UITextViewDelegate method
    func textViewDidChange(_ textView: UITextView) {
        // Calculate the new size based on content
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        
        // Check if the text view's size has changed
        if newSize.height != textView.frame.size.height {
            UIView.animate(withDuration: 0.2) {
                // Update the height of the textView
                textView.frame.size.height = newSize.height
                
                // Update the layout for all subsequent text views and indicators
                self.updateLayoutForTextViewChanges(textView)
            }
        }
        
        
    }
    
    
    public func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshStockData(_:)), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }
    
}
