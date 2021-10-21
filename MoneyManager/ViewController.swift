//
//  ViewController.swift
//  MoneyManager
//
//  Created by Иван on 10/12/21.
//

import UIKit

class ViewController: UIViewController {
    
    var stillTyping = false
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet var keyboardButtons: [UIButton]!
    
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
    
    
}

