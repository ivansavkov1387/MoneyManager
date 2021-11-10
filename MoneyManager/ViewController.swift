//
//  ViewController.swift
//  MoneyManager
//
//  Created by Иван on 10/12/21.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    let realm = try! Realm()
    var spendingArray: Results<Spending>!
    
    var stillTyping = false
    var categoryName = ""
    var displayValue = 1
    
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet var keyboardButtons: [UIButton]!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var howManyCanSpendLabel: UILabel!
    @IBOutlet weak var spendByCheckLabel: UILabel!
    @IBOutlet weak var allSpendLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spendingArray = realm.objects(Spending.self)
        leftLabels()
        allSpending()
        
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        
        let number = sender.currentTitle!
        
        if number == "0" && displayLabel.text == "0" {
            stillTyping = false
        } else {
            if stillTyping {
                if displayLabel.text!.count < 15 {
                    displayLabel.text = displayLabel.text! + number
                }
            } else {
                displayLabel.text = number
                stillTyping = true
            }
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        displayLabel.text = "0"
        stillTyping = false
    }
    
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        categoryName = sender.currentTitle!
        displayValue = Int(displayLabel.text!)!
        displayLabel.text = "0"
        stillTyping = false
        
        let value = Spending(value: ["\(categoryName)", displayValue])
        try! realm.write {
            realm.add(value)
        }
        
        leftLabels()
        allSpending()
        tableView.reloadData()
    }
    
    @IBAction func limitPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Установить лимит",
                                                message: "Введите сумму и количество дней",
                                                preferredStyle: .alert)
        
        let alertInstall = UIAlertAction(title: "Установить", style: .default) { _ in
            let sumTF = alertController.textFields?[0].text
            let daysTF = alertController.textFields?[1].text
            
            guard sumTF != "" && daysTF != "" else { return }
            
            self.limitLabel.text = sumTF
            self.howManyCanSpendLabel.text = sumTF
            
            let currentDate = Date()
            let lastDay = currentDate.addingTimeInterval(60*60*24*Double(daysTF!)!)
            
            let limit = self.realm.objects(Limit.self)
            if limit.isEmpty {
                let value = Limit(value: [self.limitLabel.text!, currentDate, lastDay])
                try! self.realm.write {
                    self.realm.add(value)
                }
            } else {
                try! self.realm.write {
                    limit[0].limitSum = self.limitLabel.text!
                    limit[0].limitDate = currentDate as NSDate
                    limit[0].limitLastDay = lastDay as NSDate
                }
            }

        }
                
        alertController.addAction(alertInstall)
        alertController.addTextField { (money) in
            money.placeholder = "Сумма"
            money.keyboardType = .numberPad
        }
        
        alertController.addTextField { (days) in
            days.placeholder = "Количество дней"
            days.keyboardType = .numberPad
        }
        
        let alertCancel = UIAlertAction(title: "Отмена", style: .default)
        alertController.addAction(alertCancel)
        present(alertController, animated: true)
        
        self.leftLabels()
        
    }
    
    func leftLabels() {
        let limit = realm.objects(Limit.self)
        
        guard !limit.isEmpty else { return }
        
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let firstDay = limit[0].limitDate as Date
        let lastDay = limit[0].limitLastDay as Date
        
        let firstComponent = calendar.dateComponents([.year, .month, .day], from: firstDay)
        let lastComponent = calendar.dateComponents([.year, .month, .day], from: lastDay)
        
        let startDate = formatter.date(from: "\(firstComponent.year!)/\(firstComponent.month!)/\(firstComponent.day!) 00:00")
        let finishDate = formatter.date(from: "\(lastComponent.year!)/\(lastComponent.month!)/\(lastComponent.day!) 23:59")
        
        let filteredLimit: Int = realm.objects(Spending.self).filter("self.date >= %@ && self.date <= %@", startDate!, finishDate!).sum(ofProperty: "cost")
        
        spendByCheckLabel.text = "\(filteredLimit)"
        
        let limitOnLabel = Int(limitLabel.text!)!
        let spendByCheckLabel = Int(self.spendByCheckLabel.text!)!
        let availableMoneyLabel = limitOnLabel - spendByCheckLabel
        howManyCanSpendLabel.text = "\(availableMoneyLabel)"
        
    }
    
    func allSpending() {
        let allSpend: Int = realm.objects(Spending.self).sum(ofProperty: "cost")
        allSpendLabel.text = "\(allSpend)"
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        let spending = spendingArray.sorted(byKeyPath: "date", ascending: false)[indexPath.row]
        cell.recordCategory.text = spending.category
        cell.recordCost.text = String(spending.cost)
        
        switch spending.category {
        case "Еда": cell.imageView?.image = #imageLiteral(resourceName: "Category_Еда")
        case "Одежда": cell.imageView?.image = #imageLiteral(resourceName: "Category_Одежда")
        case "Связь": cell.imageView?.image = #imageLiteral(resourceName: "Category_Связь")
        case "Досуг": cell.imageView?.image = #imageLiteral(resourceName: "Category_Досуг")
        case "Красота": cell.imageView?.image = #imageLiteral(resourceName: "Category_Красота")
        case "Авто": cell.imageView?.image = #imageLiteral(resourceName: "Category_Авто")
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let editingRow = spendingArray.sorted(byKeyPath: "date", ascending: false)[indexPath.row]
            try! realm.write {
                realm.delete(editingRow)
            }
            
            leftLabels()
            allSpending()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            

            
        }
    }
    
}

