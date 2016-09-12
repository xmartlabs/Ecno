//
//  Since.swift
//  Ecno
//
//  Created by Diego Ernst on 9/9/16.
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public enum Scope: Equatable {

    case appInstall
    case appVersion
    case appSession
    case since(TimeInterval)
    case until(TimeInterval)

}

public func == (s1: Scope, s2: Scope) -> Bool {
    switch (s1, s2) {
    case (.appInstall, .appInstall):
        return true
    case (.appVersion, .appVersion):
        return true
    case (.appSession, .appSession):
        return true
    case let (.since(t1), .since(t2)):
        return t1.timeInterval == t2.timeInterval
    default:
        return false
    }
}

extension Scope {

    func toDictionary() -> [AnyHashable: Any] {
        var dict = [AnyHashable: Any]()
        switch self {
        case .appInstall:
            dict["name"] = "appInstall"
        case .appVersion:
            dict["name"] = "appVersion"
        case .appSession:
            dict["name"] = "appSession"
        case let .since(time):
            dict["name"] = "since"
            dict["timeInterval"] = time.timeInterval
            dict["referenceDate"] = Date()
        case let .until(time):
            dict["name"] = "until"
            dict["timeInterval"] = time.timeInterval
            dict["referenceDate"] = Date()
        }
        return dict
    }

    static func fromDictionary(_ dict: [AnyHashable: Any]) -> Scope? {
        guard let name = dict["name"] as? String else { return nil }
        switch name {
        case "appInstall":
            return .appInstall
        case "appVersion":
            return .appVersion
        case "appSession":
            return .appSession
        case "since":
            guard let reference = dict["referenceDate"] as? Date else { return nil }
            guard let time = dict["timeInterval"] as? Foundation.TimeInterval else { return nil }
            return .since((abs(reference.timeIntervalSinceNow) + time).seconds)
        case "until":
            guard let reference = dict["referenceDate"] as? Date else { return nil }
            guard let time = dict["timeInterval"] as? Foundation.TimeInterval else { return nil }
            return .until((reference.timeIntervalSinceNow + time).seconds)
        default:
            return nil
        }
    }

}
