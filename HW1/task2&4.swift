import Foundation

enum OperatorType: Character {
    case add = "+", sub = "-", div = "/", mul = "*", pow = "^", neg = "n"
}

enum MathTokenType {
case num, oper, variable, lBracket, rBracket
}

protocol MathToken {
    var tokenType: MathTokenType {get}
}

enum Associativity {
    case left, right
}

struct Operator: MathToken {
    var tokenType = MathTokenType.oper
    var operatorType: OperatorType
    var precedence: Int {
        switch operatorType {
            case .add, .sub: return 2
            case .mul, .div: return 3
            case .pow, .neg: return 4
        }
    }

    var associativity: Associativity {
      switch operatorType {
          case .add, .sub, .mul, .div: return Associativity.left
          case .pow, .neg: return Associativity.right
        }
    }

    init(_ value: Character) {
        switch value {
            case "+": operatorType = .add
            case "-": operatorType = .sub
            case "*": operatorType = .mul
            case "/": operatorType = .div
            case "^": operatorType = .pow
			case "n": operatorType = .neg
            default: operatorType = .add
        }
    }

    var isLeftAssociative: Bool {
        return self.associativity == .left
    }

    var isRightAssociative: Bool {
        return self.associativity == .right
    }
}

struct Operand: MathToken {
    var tokenType = MathTokenType.num
    let value: Double

    init(_ val: Double) {
        value = val
    }
}

struct Bracket: MathToken {
    var tokenType: MathTokenType

    init(_ value: Character) {
        switch value {
            case "(": tokenType = .lBracket
            case ")": tokenType = .rBracket
            default: tokenType = .lBracket
        }
    }
}

struct Variable: MathToken {
    var tokenType = MathTokenType.variable
    let name: String

    init(name: String) {
        self.name = name
    }
}




class ConstantMathematicalExpression {
    let expression: String

    var tokens: [MathToken]?

    var postfixExpression: [MathToken] {
		return infixToPostfix(tokens!)
	}

    var value: Double {
		return calculate(postfixExpression)
	}

    init(_ expression: String) {
        self.expression = expression
        self.tokens = parse(self.expression)
        //self.postfixExpression = infixToPostfix(self.tokens!)
        //self.value = calculate(self.postfixExpression!)
    }

    func parse(_ input: String) -> [MathToken] {
        var output = [MathToken]()
        var num = ""
        var variable = ""

        for char in input.characters {

            switch char {
            case "(":
                if !num.isEmpty {
                    output.append(Operand(Double(num)!))
                    num = ""
                }
                if !variable.isEmpty {
                    output.append(Variable(name: variable))
                    variable = ""
                }
                output.append(Bracket(char))
            case ")":
                if !num.isEmpty {
                    output.append(Operand(Double(num)!))
                    num = ""
                }
                if !variable.isEmpty {
                    output.append(Variable(name: variable))
                    variable = ""
                }
                output.append(Bracket(char))
			case "-":
				if !num.isEmpty {
                    output.append(Operand(Double(num)!))
                    num = ""
                }
                if !variable.isEmpty {
                    output.append(Variable(name: variable))
                    variable = ""
                }
				if output.isEmpty {
					output.append(Operator("n"))
				} else if output.last is Operator {
					output.append(Operator("n"))
				} else if output.last is Bracket {
					if (output.last as! Bracket).tokenType == .lBracket {
						output.append(Operator("n"))
					} else {
						output.append(Operator("-"))
					}
				} else {
					output.append(Operator("-"))
				}
            case "+", "*", "/", "^":
                if !num.isEmpty {
                    output.append(Operand(Double(num)!))
                    num = ""
                }
                if !variable.isEmpty {
                    output.append(Variable(name: variable))
                    variable = ""
                }
                output.append(Operator(char))
            case let x where "0" <= x && x <= "9" || x == ".":
                num.append(char)
            case let x where "a" <= x && x <= "z" || "A" <= x && x <= "Z":
                variable.append(char)
            default:
                continue
            }
        }
        if !num.isEmpty {
            output.append(Operand(Double(num)!))
            num = ""
        }
        if !variable.isEmpty {
            output.append(Variable(name: variable))
            variable = ""
        }

        return output
    }

    func infixToPostfix(_ tokens: [MathToken]) -> [MathToken] {
        var stack = [MathToken]()
        var queue = [MathToken]()

        for token in tokens {
            switch token {
                case is Operand:
                    queue.append(token)
                case is Variable:
                    queue.append(token)
                case let operOne where operOne is Operator:
                    let operator_copy = operOne as! Operator
                    while (!stack.isEmpty && stack.last is Operator) {
                        if (operator_copy.isLeftAssociative &&
                            operator_copy.precedence <= (stack.last as! Operator).precedence) ||
                            (operator_copy.isRightAssociative &&
                            operator_copy.precedence < (stack.last as! Operator).precedence) {
                                queue.append(stack.removeLast())
                        } else {
                            break
                        }
                    }
                    stack.append(operOne)
                case let lb where lb is Bracket && lb.tokenType == MathTokenType.lBracket:
                    stack.append(lb)
                case let rb where rb is Bracket && rb.tokenType == MathTokenType.rBracket:
                    while(!stack.isEmpty &&
    					  !(stack.last is Bracket && (stack.last as! Bracket).tokenType == MathTokenType.lBracket)) {
                        if stack.last is Operator {
                            queue.append(stack.removeLast())
                        }
                    }

                    if(stack.last is Bracket && (stack.last as! Bracket).tokenType == MathTokenType.lBracket) {
                        stack.removeLast()
                    }
                default:
                    continue
            }
        }

        while !stack.isEmpty && stack.last is Operator {
          queue.append(stack.removeLast())
        }

        return queue
    }

    func calculate(_ tokens: [MathToken]) -> Double {
        var stack = [Double]()

        for token in tokens {
            if token is Operand {
                stack.append((token as! Operand).value)
            } else {
              switch token {
                  case let t where (t as! Operator).operatorType == OperatorType.add:
                      let a = stack.removeLast()
                      let b = stack.removeLast()
                      stack.append(a + b)
                  case let t where (t as! Operator).operatorType == OperatorType.sub:
                      let a = stack.removeLast()
                      let b = stack.removeLast()
                      stack.append(b - a)
                  case let t where (t as! Operator).operatorType == OperatorType.mul:
                      let a = stack.removeLast()
                      let b = stack.removeLast()
                      stack.append(a * b)
                  case let t where (t as! Operator).operatorType == OperatorType.div:
                      let a = stack.removeLast()
                      let b = stack.removeLast()
                      stack.append(b / a)
                  case let t where (t as! Operator).operatorType == OperatorType.pow:
                      let a = stack.removeLast()
                      let b = stack.removeLast()
                      stack.append(pow(b, a))
				  case let t where (t as! Operator).operatorType == OperatorType.neg:
				      let a = stack.removeLast()
				  	  stack.append(-a)
                  default:
                      continue
              }

            }
        }

        return stack.last!
    }
}


class VariableMathematicalExpression: ConstantMathematicalExpression {
    let variables: [String:Double]

    init(_ expression: String, variables: [String:Double]) {
        self.variables = variables
		super.init(expression)
		replaceVariablesWithConstants(&super.tokens!)
	}

    func replaceVariablesWithConstants(_ t: inout [MathToken]) {
        for (index, token) in t.enumerated() {
            if token is Variable {
                let val: Double = variables[(token as! Variable).name]!
                tokens![index] = Operand(val)
            }
        }
    }
}

let a = ConstantMathematicalExpression("(3-4)*5")
print(a.value)

let b = ConstantMathematicalExpression("5 + ((1 + 2) * 4) - 3")
print(b.value)

let c = ConstantMathematicalExpression("2^-1 + 3")
print(c.value)

let x = VariableMathematicalExpression("d ^ b + c", variables: ["b":-1, "d":2, "c":3])
print(x.value)

let y = VariableMathematicalExpression("a + ((b + c) * d) - e", variables: ["a":5, "b":1, "c":2, "d":4, "e":3])
print(y.value)

let z = VariableMathematicalExpression("a*x^2 + b*x + c", variables: ["a":1, "b":3, "c":-4, "x":1])
print(z.value)