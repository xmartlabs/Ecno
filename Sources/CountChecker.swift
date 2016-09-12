//
//  CountChecker.swift
//  Twice
//
//  Created by Diego Ernst on 9/12/16.
//
//

import Foundation

public enum CountChecker {

    case equal(Int)
    case moreThan(Int)
    case lessThan(Int)

    func check(_ times: Int) -> Bool {
        switch self {
        case let .equal(count):
            return times == count
        case let .moreThan(count):
            return times > count
        case let .lessThan(count):
            return times < count
        }
    }

}
