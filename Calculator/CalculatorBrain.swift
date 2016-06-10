//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Vili Lähtevänoja on 02/06/16.
//  Copyright © 2016 Vili Lähtevänoja. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var operationsSequence = ""
    private var accumulatorValueIsFromUnaryOperation = false
    private var isOperandConstant = false
    private var operandConstantSymbol: String? = nil
    private var internalProgram = [AnyObject]()
    
    var variableValues: Dictionary<String, Double> = ["M" : 0]
    
    var description: String {
        get {
            /*var descriptionStr = ""
            for op in internalProgram {
                if let operand = op as? Double {
                    let isInteger = floor(operand) == operand
                    if isInteger {
                        descriptionStr += "\(String(Int(operand))) "
                    }
                    else {
                        descriptionStr += "\(String(operand)) "
                    }
                }
                else if let operation = op as? String {
                    if (operation != "=" ) {
                        descriptionStr += "\(operation) "
                    }
                }
            }
            return descriptionStr*/
            return operationsSequence
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
        if (!isPartialResult) {
            operationsSequence = ""
        }
        if (pending == nil) {
            let isInteger = floor(operand) == operand
            if (isInteger) {
                operationsSequence += " \(Int(operand)) "
            }
            else {
                operationsSequence += " \(operand) "
            }
        }
    }
    
    func setOperand(variableName: String) {
        accumulator = variableValues[variableName]!
        if (!isPartialResult) {
            operationsSequence = ""
        }
        if (pending == nil) {
            operationsSequence += " \(variableName) "
        }
    }
    
    var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "±" : Operation.UnaryOperation({ -$0 }),
        "√" : Operation.UnaryOperation(sqrt),
        "sin": Operation.UnaryOperation(sin),
        "cos" : Operation.UnaryOperation(cos),
        "tan": Operation.UnaryOperation(tan),
        "log": Operation.UnaryOperation(log10),
        "pow" : Operation.BinaryOperation(pow),
        "×": Operation.BinaryOperation({ $0 * $1 }),
        "÷": Operation.BinaryOperation({ $0 / $1 }),
        "+": Operation.BinaryOperation({ $0 + $1 }),
        "-": Operation.BinaryOperation({ $0 - $1 }),
        "%": Operation.UnaryOperation ({ $0 * 0.01 }),
        "=": Operation.Equals
    ]
    
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                isOperandConstant = true
                operandConstantSymbol = symbol
            case .UnaryOperation(let function):
                if (pending == nil) {
                    operationsSequence = "\(symbol)(" + operationsSequence + ")"
                }
                else {
                    operationsSequence += "\(symbol)(\(accumulator)) "
                }
                accumulator = function(accumulator)
                accumulatorValueIsFromUnaryOperation = true
                isOperandConstant = false
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                if (symbol != "=") {
                    operationsSequence += " \(symbol) "
                }
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            if (!accumulatorValueIsFromUnaryOperation) {
                if isOperandConstant {
                    operationsSequence += " \(operandConstantSymbol!) "
                    operandConstantSymbol = nil
                }
                else {
                    operationsSequence += " \(accumulator) "
                }
            }
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            accumulatorValueIsFromUnaryOperation = false
            pending = nil
            isOperandConstant = false
            operandConstantSymbol = nil
        }
    }

    private var pending: PendingBinaryOperationInfo?
    
    struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    func reset() {
        pending = nil
        accumulator = 0
        internalProgram.removeAll()
        for (key, _) in variableValues {
            variableValues[key] = 0.0
        }
    }
    
    
    
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            reset()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}