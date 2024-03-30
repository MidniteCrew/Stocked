//
//  ViewController.swift
//  Stocked
//
//  Created by Gabriel Ungur on 2023-12-23.
//

import UIKit
import AudioToolbox // For vibration


class TextViewManager {
    static let shared = TextViewManager()
    
    var textViews: [UITextView] = []
    
    var cumulativeDataKey = "cumulativeData"
    var cumulativeData: [DataPoint] = [] {
        
        didSet {
            saveCumulativeData()
            }
        
    }

    private init() {} // Private initializer to ensure only one instance is created
}

//For textviewmanager:
private func saveCumulativeData() {
        do {
            let data = try JSONEncoder().encode(TextViewManager.shared.cumulativeData)
            UserDefaults.standard.set(data, forKey: TextViewManager.shared.cumulativeDataKey)
        } catch {
            print("Failed to save cumulative data: \(error)")
        }
    }



class ViewController: UIViewController, UITextViewDelegate {
    
    //Naming the view that corresponds to the mainMenu
    @IBOutlet weak var Main_Menu: UIView!
    @IBOutlet weak var totalPositionValueLabel: UILabel!
    
    
    let textViewHeight: CGFloat = 100
    let spacing: CGFloat = 7 // Spacing between text views
   
    var textViews: [UITextView] {
          get {
              return TextViewManager.shared.textViews
          }
          set {
              TextViewManager.shared.textViews = newValue
          }
      }
    
    
    var refreshTimer: Timer?
    
    var originalTextViewHeight: CGFloat = 100 // Set your initial height here
    var textViewToStockSymbol: [UITextView: String] = [:]
    var stockPrices: [String: Double] = [:]
    var scrollTimer: Timer?
    var showPercentage = true // Add this property at class level
    var selectedPlatform: String?
    var platforms: [String] = []
    var platformToTextViews: [String: [UITextView]] = [:]
    var platformTextViewVisibility: [String: Bool] = [:]
    var platformContainers: [String: UIView] = [:]

    
    
    // Add the isEditingMode property
    var isEditingMode = false  // This variable tracks the editing state
    var selectionIndicators = [UITextView: UIButton]() // Maps text views to their indicators
    var selectedTextViews = Set<UITextView>()
    var overlayView: UIView!
    var menuView: UIView!
    
    public var exitButton: UIButton!
    public let refreshControl = UIRefreshControl()
    

    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        
        // Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare() // Preloads the necessary resources to reduce latency
        generator.impactOccurred()
        
        // Toggle the menu view
        let isMenuOpen = menuView.frame.origin.x >= 0
        let newOriginX = isMenuOpen ? -menuView.frame.width : 0
        UIView.animate(withDuration: 0.3) {
            self.menuView.frame.origin.x = newOriginX
        }
        
        // Show the overlay view
        overlayView.isHidden = false
        self.view.bringSubviewToFront(menuView)
    }
    
    override func viewDidLoad() {
        
        // Calculate one-third of the screen width
        
        let screenWidth = UIScreen.main.bounds.width
        let menuWidth = screenWidth / 2.3
        menuView = UIView(frame: CGRect(x: -menuWidth, y: 0, width: menuWidth, height: self.view.frame.height))
        // Set the background color to a very dark shade, almost black but slightly lighter
        menuView.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1)
        
        self.view.addSubview(menuView)
        
        super.viewDidLoad()
        setupDeleteButton()
        setupRefreshControl()
        // Load saved data when the app is launched
        loadSavedData()
        deleteButton.isHidden = true  // Hide delete button initially
        scrollView.alwaysBounceVertical = true
        var showPercentage = true // When true, show percentage; otherwise, show dollar amount
        
        
        //THIS CODE MAY BE USED FROM SMT. IDK.
        let tapGesture_TotalValue = UITapGestureRecognizer(target: self, action: #selector(totalPositionValueLabelTapped))
        totalPositionValueLabel.isUserInteractionEnabled = true
        totalPositionValueLabel.addGestureRecognizer(tapGesture_TotalValue)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideMenu))
        swipeGesture.direction = .left
        menuView.addGestureRecognizer(swipeGesture)
        
        // Initialize and configure the close button
        closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeMenu), for: .touchUpInside)
        
        // Configure the close button's frame
        let buttonWidth: CGFloat = 60
        let buttonHeight: CGFloat = 30
        let buttonX: CGFloat = 10  // Left margin
        let buttonY: CGFloat = 100 // Adjust this value to move the button down
        
        closeButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)
        menuView.addSubview(closeButton)
        
        menuView.addSubview(closeButton)
        
        // Initialize the overlay view
        overlayView = UIView(frame: self.view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent black
        overlayView.isHidden = true // Hidden by default
        overlayView.isUserInteractionEnabled = true // Enable user interaction
        
        // Add a tap gesture recognizer to the overlay view
        let tapGesture_Settings_Menu = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlayView.addGestureRecognizer(tapGesture_Settings_Menu)
        
        self.view.addSubview(overlayView)
        
        //setupPlatformButton()
        setupThemeButton()
        
        // Initialize the "Exit" button
        exitButton = UIButton(type: .system)
        exitButton.setTitle("Exit", for: .normal)
        exitButton.addTarget(self, action: #selector(exitThemeMode), for: .touchUpInside)
        
        // Position it where the "Settings" button is
        exitButton.frame = settingsButton.frame
        
        // Hide it initially
        exitButton.isHidden = true
        
        // Add it to the view
        view.addSubview(exitButton)
        
        
        setupPlatformsButton() // Assuming you have a method to setup and add the Platforms button
        
        if let savedPlatforms = UserDefaults.standard.array(forKey: "SavedPlatforms") as? [String] {
            platforms = savedPlatforms
        }
        
        refreshStockData()
        
        // Assuming your ViewController is within a UITabBarController
        if let tabBarController = self.tabBarController {
            tabBarController.delegate = self
        }
        
        
        // Add swipe gesture recognizer to detect right swipe
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeRightGesture.direction = .right
        view.addGestureRecognizer(swipeRightGesture)
        
        // Other setup code...
        // Setup the timer to call refreshStockData every 40 seconds
        refreshTimer = Timer.scheduledTimer(timeInterval: 40, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }
    
    deinit {
            // Invalidate the timer when the view controller is de-allocated to prevent it from firing if the view controller is no longer in memory
            refreshTimer?.invalidate()
        }
    
    @objc func timerFired(_ timer: Timer) {
        // Call the refreshStockData method without parameters
        refreshStockData(silent: true)
        //Update total position value
        updateTotalPositionValue()
    }
    
    
    
       @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
           if gesture.direction == .right {
               // Trigger the platformButton tapped action
               PlatformButtonTapped()
           }
       }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        repositionTextViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !textViews.isEmpty {
            refreshStockData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateScrollViewContentSize()
    }
    
    @IBOutlet weak var AddButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func AddButton(_ sender: Any) {
    
        presentCryptocurrencyEntryAlert()
        let generator = UIImpactFeedbackGenerator(style: .rigid)
          generator.prepare() // This line is optional; it preloads the necessary resources to reduce latency
          generator.impactOccurred()
        /* This code asked the user if they had crypto or stock
        let optionMenu = UIAlertController(title: nil, message: "Choose Type", preferredStyle: .actionSheet)
        
        let stocksAction = UIAlertAction(title: "Stocks", style: .default) { [weak self] _ in
            // Call the function to handle stock entry
            self?.presentStockEntryAlert()
        }
        
        let cryptocurrencyAction = UIAlertAction(title: "Cryptocurrency", style: .default) { [weak self] _ in
            // Call the function to handle cryptocurrency entry
            self?.presentCryptocurrencyEntryAlert()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(stocksAction)
        optionMenu.addAction(cryptocurrencyAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true)
         
         */
    }

    @IBOutlet weak var settingsButton: UIButton!
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.prepare() // This line is optional; it preloads the necessary resources to reduce latency
            generator.impactOccurred()

            isEditingMode = !isEditingMode
            updateTextViewsForEditingMode()

            // Update the visibility of the delete button based on the editing mode AND whether any text views are selected
            deleteButton.isHidden = !isEditingMode || selectedTextViews.isEmpty

            // Disable the "Add" button when entering edit mode
            AddButton.isEnabled = !isEditingMode

            // Optionally change the button's title based on the state
            sender.setTitle(isEditingMode ? "Done" : "Edit", for: .normal)

            // Update the visibility of the settings button
            settingsButton.isHidden = isEditingMode
        }
    
    //Creating an outlet for the "Edit" button
    @IBOutlet weak var editButton: UIButton!
    
    

  
    
    
    
    
    
 
    
  
    
    
    
    
    

    
    
    
}

