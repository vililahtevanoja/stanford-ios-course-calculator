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
    @IBOutlet private weak var operationSequenceDisplay: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    private var userTypingInteger = true
    
    @IBAction func clearCalculator(sender: UIButton) {
        displayValue = 0
        display!.text = "0"
        operationSequenceDisplayValue = " "
        brain = CalculatorBrain()
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        let textCurrentlyInDisplay = display!.text!
        if userIsInTheMiddleOfTyping {
            if digit == "." && userTypingInteger {
                userTypingInteger = false
                display!.text = textCurrentlyInDisplay + digit
            }
            if digit == "." && !userTypingInteger {
                // do nothing
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
            if floor(newValue) == newValue {
                display.text = String(Int(newValue))
            }
            else {
                display.text = String(newValue)
            }
        }
    }
    
    private var operationSequenceDisplayValue: String {
        get {
            if let text = operationSequenceDisplay.text {
                return text
            }
            else {
                return ""
            }
        }
        set {
            operationSequenceDisplay.text = newValue
        }
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func setVariable(sender: UIButton) {
        brain.variableValues[sender.currentTitle!] = displayValue
    }
    
    
    @IBAction func getVariable(sender: UIButton) {
        let senderTitle = sender.currentTitle!
        let letters = NSCharacterSet.letterCharacterSet()
        let variable = String(
            UnicodeScalar(
                senderTitle
                    .unicodeScalars
                    .filter({ letters.longCharacterIsMember($0.value)})
                    .first!
            )
        )
        brain.setOperand(variable)
    }
    
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
            userTypingInteger = true
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            operationSequenceDisplayValue = brain.description
            if brain.isPartialResult {
                operationSequenceDisplayValue = brain.description + " ..."
                displayValue = brain.result
            }
            else {
                displayValue = brain.result
                operationSequenceDisplayValue = brain.description + " ="
            }
        }
    }
}
