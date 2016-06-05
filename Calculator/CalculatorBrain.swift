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
    
    var description: String {
        get {
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
        operationsSequence += "\(String(operand))"
        print(operationsSequence)
    }
    
    var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "±" : Operation.UnaryOperation({ -$0 }),
        "√" : Operation.UnaryOperation(sqrt),
        "pow" : Operation.BinaryOperation(pow),
        "sin": Operation.UnaryOperation(sin),
        "cos" : Operation.UnaryOperation(cos),
        "tan": Operation.UnaryOperation(tan),
        "log": Operation.UnaryOperation(log10),
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
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                if (symbol != "=") {
                    operationsSequence += " \(symbol) "
                }
                print(operationsSequence)
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
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
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}