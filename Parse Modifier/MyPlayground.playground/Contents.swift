//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
let x = "Ashuelot River Park"
let y = "Ashuelot Quest River Park"

let difference = zip(x.characters, y.characters).filter{$0 != $1}
print(difference.count)