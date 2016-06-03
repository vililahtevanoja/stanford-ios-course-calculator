//
//  ViewController.swift
//  Calculator
//
//  Created by Vili Lähtevänoja on 01/06/16.
//  Copyright © 2016 Vili Lähtevänoja. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    private var userTypingInteger = true
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        let textCurrentlyInDisplay = display!.text!
        if userIsInTheMiddleOfTyping {
            if digit == "." && userTypingInteger  {
                userTypingInteger = false
                display!.text = textCurrentlyInDisplay + digit
            }
            else {
                display!.text = textCurrentlyInDisplay + digit
            }
        } else {
            display!.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
            userTypingInteger = true
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
    }
}
