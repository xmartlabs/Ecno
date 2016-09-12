//
//  TimeInterval.swift
//  Twice
//
//  Created by Diego Ernst on 9/12/16.
//
//

import Foundation

public enum TimeInterval {

    case days(Double)
    case hours(Double)
    case minutes(Double)
    case seconds(Double)

    var timeInterval: Foundation.TimeInterval {
        switch self {
        case let .days(n):
            return Double(n * 24 * 60 * 60)
        case let .hours(n):
            return Double(n * 60 * 60)
        case let .minutes(n):
            return Double(n * 60)
        case let .seconds(n):
            return Double(n)
        }
    }

}

public extension Double {

    var days: TimeInterval { return .days(self) }
    var hours: TimeInterval { return .hours(self) }
    var minutes: TimeInterval { return .minutes(self) }
    var seconds: TimeInterval { return .seconds(self) }

}
