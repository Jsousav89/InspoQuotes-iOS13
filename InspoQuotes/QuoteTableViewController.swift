//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Angela Yu on 18/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController {
    
    let productID = "com.resultoconsultoria.InspoQuotes.PremiumQuotes"
    var enabledSections = 1
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
        if isPurchased() {
            showPremiumQuotes()
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        enabledSections
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
       if section == 0 {
           return "Free Quotes"
       } else if section == 1 {
           return "Premium Quotes"
       } else { return nil }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return enabledSections == 1 ? quotesToShow.count + 1 : quotesToShow.count
        } else if section == 1 {
            return premiumQuotes.count
        } else { return 0 }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        
        cell.textLabel?.numberOfLines = 0
        
        if indexPath.section == 0 {
            if indexPath.row < quotesToShow.count {
                cell.textLabel?.text = quotesToShow[indexPath.row]
            } else if enabledSections == 1 {
                cell.textLabel?.text = "Tell me more!!"
                cell.textLabel?.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                cell.accessoryType = .disclosureIndicator
            }
        } else if indexPath.section == 1 {
            cell.textLabel?.text = premiumQuotes[indexPath.row]
            cell.textLabel?.textColor = nil
            cell.accessoryType = .none
        }
        
        return cell
    }
    

    // MARK: - Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == quotesToShow.count {
            buyPremiumQuotes()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - In-App Purchase Methods

    func buyPremiumQuotes() {
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
            
        } else {
            print("User can't make payments")
        }
    }
    
    func showPremiumQuotes() {
        enabledSections = 2
        tableView.reloadData()
    }
    
    func isPurchased() -> Bool {
        UserDefaults.standard.bool(forKey: productID)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

}

// MARK: - Payment Transaction Observer

extension QuoteTableViewController: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                //Payment successful
                print("Transaction successful!")
                showPremiumQuotes()
                
                UserDefaults.standard.set(true, forKey: productID)
                
                navigationItem.setRightBarButton(nil, animated: true)
                
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                //Payment failed
                print("Transaction failed!")
                
                if let error = transaction.error {
                    let description = error.localizedDescription
                    print("Transaction failed due: \(description)")
                }
                
                SKPaymentQueue.default().finishTransaction(transaction)
            case .purchasing:
                
                print("Purchasing....")

            default:
                print(transaction.transactionState)
                
            }
        }
    }

}

