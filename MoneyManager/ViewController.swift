//
//  ViewController.swift
//  MoneyManager
//
//  Created by Иван on 10/12/21.
//

import UIKit

class ViewController: UIViewController {
    
    var stillTyping = false
    var categoryName = ""
    var displayValue = ""
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet var keyboardButtons: [UIButton]!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        
        let number = sender.currentTitle!
        
        if stillTyping {
            if displayLabel.text!.count < 15 {
                displayLabel.text = displayLabel.text! + number
            }
        } else {
            displayLabel.text = number
            stillTyping = true
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        displayLabel.text = "0"
        stillTyping = false
    }
    
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        categoryName = sender.currentTitle!
        displayValue = displayLabel.text!
        displayLabel.text = "0"
        stillTyping = false
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
    
    
}

