//
//  Since.swift
//  Twice
//
//  Created by Diego Ernst on 9/9/16.
//
//

import Foundation

public enum Scope {

    case appInstall
    case appVersion
    case appSession
    case since(TimeInterval)
    case until(TimeInterval)

}

func ==(s1: Scope, s2: Scope) -> Bool {
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

func !=(s1: Scope, s2: Scope) -> Bool {
    return !(s1 == s2)
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
