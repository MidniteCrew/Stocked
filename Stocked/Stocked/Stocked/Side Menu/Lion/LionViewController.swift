//Created by Gabriel Ungur on 2024-02-01

import UIKit

class LionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    private var messagesTableView: UITableView!
    private var messageInputField: UITextField!
    private var messages: [Message] = [] // Array to store messages
    
    struct Message {
        var text: String
        // Add more properties as needed (e.g., isSender, timestamp)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize with some example messages
        messages = [Message(text: "Hello! How can I help you today?")]
        
        view.backgroundColor = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1.0)
        setupMessagesTableView()
        setupMessageInputField()
        setupNavigationBar()
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add tap gesture recognizer to detect taps outside the typing area
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideTextField))
        view.addGestureRecognizer(tapGesture)

        // Add swipe down gesture recognizer to dismiss keyboard
         let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
         swipeDownGesture.direction = .down
         view.addGestureRecognizer(swipeDownGesture)
         
        
    }
    
    @objc private func handleTapOutsideTextField() {
        // Resign first responder status of the text field to dismiss the keyboard and exit typing mode
        messageInputField.resignFirstResponder()
    }
    
    @objc private func handleSwipeDown() {
        // Dismiss the keyboard by resigning first responder status of the text field
        messageInputField.resignFirstResponder()
    }
       @objc func keyboardWillShow(notification: NSNotification) {
           if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
               if view.frame.origin.y == 0 {
                   view.frame.origin.y -= keyboardSize.height
               }
           }
       }

       @objc func keyboardWillHide(notification: NSNotification) {
           if view.frame.origin.y != 0 {
               view.frame.origin.y = 0
           }
       }

    private func setupMessagesTableView() {
        messagesTableView = UITableView()
        messagesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")
        messagesTableView.dataSource = self
        messagesTableView.delegate = self

        messagesTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messagesTableView)

        let navigationBarHeight: CGFloat = 45 // Standard navigation bar height
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let topInset = navigationBarHeight + statusBarHeight

        NSLayoutConstraint.activate([
            messagesTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: topInset), // Adjusted to be below the navigation bar
            messagesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messagesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messagesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }


    private func setupMessageInputField() {
        messageInputField = UITextField()
        messageInputField.delegate = self
        messageInputField.placeholder = "Type a message..."
        messageInputField.borderStyle = .roundedRect
        messageInputField.textColor = .white
        
        // Create a send button
        let sendButton = UIButton(type: .system)
        let arrowUpImage = UIImage(systemName: "arrow.up.circle")
        sendButton.setImage(arrowUpImage, for: .normal)
        sendButton.setTitle("  ", for: .normal) // Set the title
        sendButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5) // Add padding between image and text
        sendButton.tintColor = .darkGray // Set the tint color as needed
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.setTitleColor(.darkGray, for: .normal) // Initial color
        
        // Add the send button to the input field
        messageInputField.rightView = sendButton
        messageInputField.rightViewMode = .always
        
        messageInputField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageInputField)
        
        NSLayoutConstraint.activate([
            messageInputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            messageInputField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            messageInputField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            messageInputField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func sendButtonTapped() {
        if let text = messageInputField.text, !text.isEmpty {
            // Create a new message object for the user's message and append it to the messages array
            let userMessage = Message(text: text)
            messages.append(userMessage)

            // Reload the table view to display the new message
            messagesTableView.reloadData()

            // Send the message to Wit.ai
            sendMessageToWitAI(message: text)

            // Clear the text field
            messageInputField.text = ""

            // Exit typing mode (dismiss keyboard)
            messageInputField.resignFirstResponder()
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Update send button color based on text input
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText.isEmpty {
                if let sendButton = textField.rightView as? UIButton {
                    sendButton.setTitleColor(.darkGray, for: .normal)
                }
            } else {
                if let sendButton = textField.rightView as? UIButton {
                    sendButton.setTitleColor(.white, for: .normal)
                }
            }
        }
        return true
    }


    // MARK: - UITableViewDataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return messages.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
            
            let message = messages[indexPath.row]
            cell.textLabel?.text = message.text

            return cell
        }

    // MARK: - UITableViewDelegate Methods

    // Implement any delegate methods you need, for example, to adjust cell height

    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            // Create a new message object for the user's message and append it to the messages array
            let userMessage = Message(text: text)
            messages.append(userMessage)

            // Reload the table view to display the new message
            messagesTableView.reloadData()

            // Send the message to Wit.ai
            sendMessageToWitAI(message: text)

            // Clear the text field
            textField.text = ""
        }
        
        textField.resignFirstResponder()
        return true
    }



    // Add any additional functions or logic for handling messages here

    private func setupNavigationBar() {
        let navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)

        let navItem = UINavigationItem(title: "Lion")
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navItem.leftBarButtonItem = backButton

        navigationBar.setItems([navItem], animated: false)

        // Set the navigation bar color to match the view controller's background color
        let backgroundColor = UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1.0)
        navigationBar.barTintColor = backgroundColor

        // Make the navigation bar non-translucent
        navigationBar.isTranslucent = false // This line removes the translucency

        // Adjust the title font size and letter spacing
        let titleFontAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24),
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.kern: 1.2 // Increase letter spacing
        ] as [NSAttributedString.Key : Any]

        navigationBar.titleTextAttributes = titleFontAttributes
        navigationBar.tintColor = UIColor.white // Color for the back button and other bar button items

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }




       @objc func backButtonTapped() {
           // Dismiss the current view controller
           dismiss(animated: true, completion: nil)
       }
    
    
    
    func sendMessageToWitAI(message: String) {
        guard let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.wit.ai/message?v=20200513&q=\(encodedMessage)") else { return }

        var request = URLRequest(url: url)
        request.addValue("KDDBGI6NRZBBTLHSFYA5WSMSGR36CUBB", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending message to Wit.ai: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received from Wit.ai")
                return
            }

            // Log the raw response for debugging
            let rawResponse = String(data: data, encoding: .utf8) ?? "Invalid UTF-8 data"
            print("Raw response from Wit.ai: \(rawResponse)")

            if let responseMessage = self.parseResponse(data: data) {
                DispatchQueue.main.async {
                    let newMessage = Message(text: responseMessage)
                    self.messages.append(newMessage)
                    self.messagesTableView.reloadData()
                }
            } else {
                print("Failed to parse the response from Wit.ai")
            }
        }
        task.resume()
    }


    
    
    func parseResponse(data: Data) -> String? {
        do {
            // Parse the JSON data into a dictionary
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
            guard let dictionary = jsonResponse as? [String: Any] else {
                print("Error: Expected top-level dictionary but did not find one")
                return nil
            }

            // Initialize an empty string to build your response
            var responseString = ""

            // Extract the 'text' field which contains the user's query
            if let text = dictionary["text"] as? String {
                responseString += "User's query: \(text)\n"
            }

            // Extract location information from the 'entities' dictionary
            if let entities = dictionary["entities"] as? [String: Any],
               let locations = entities["wit$location:location"] as? [[String: Any]],
               let firstLocation = locations.first,
               let locationName = firstLocation["body"] as? String,
               let confidence = firstLocation["confidence"] as? Double {
                responseString += "Location found: \(locationName) with confidence \(confidence)\n"
            }

            // Extract intent information from the 'intents' array
            if let intents = dictionary["intents"] as? [[String: Any]],
               let firstIntent = intents.first,
               let intentName = firstIntent["name"] as? String,
               let intentConfidence = firstIntent["confidence"] as? Double {
                responseString += "Intent detected: \(intentName) with confidence \(intentConfidence)\n"
            }

            // Check if the responseString is empty, which means nothing was extracted
            if responseString.isEmpty {
                print("No relevant information extracted from the response.")
                return nil
            } else {
                return responseString
            }

        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
            return nil
        }
    }


    
    
    
    
}
