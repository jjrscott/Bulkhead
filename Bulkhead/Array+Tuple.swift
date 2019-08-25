//
//  Array+Tuple.swift
//  Ash
//
//  Created by John Scott on 23/06/2019.
//

import Foundation

enum Tuple<Element> {
    case t0
    case t1(Element)
    case t2(Element, Element)
    case t3(Element, Element, Element)
    case t4(Element, Element, Element, Element)
    case t5(Element, Element, Element, Element, Element)
    case t([Element])

}

extension Array {
    func tuple() -> Tuple<Element> {
        
        if count == 0 {
            return .t0
        } else if count == 1 {
            return .t1(self[0])
        } else if count == 2 {
            return .t2(self[0], self[1])
        } else if count == 3 {
            return .t3(self[0], self[1], self[2])
        } else if count == 3 {
            return .t4(self[0], self[1], self[2], self[3])
        } else if count == 3 {
            return .t5(self[0], self[1], self[2], self[3], self[4])
        }
        return .t(self)
    }
    
}
