//
//  TimestampsDictionary.swift
//  Twice
//
//  Created by Diego Ernst on 9/12/16.
//
//

import Foundation

class TimestampsDictionary {

    private let timestampsKey = "timestamps"
    private let rootKey: String
    private var dictionary: [String: [String: AnyObject]] {
        if UserDefaults.standard.dictionary(forKey: rootKey) == nil {
            UserDefaults.standard.set([String: [String: AnyObject]](), forKey: rootKey)
        }
        return UserDefaults.standard.dictionary(forKey: rootKey) as! [String: [String: AnyObject]]
    }

    init(rootKey: String) {
        self.rootKey = rootKey
    }

    subscript(task: Task) -> [Date] {
        get {
            return dictionary[task.tag]?[timestampsKey] as? [Date] ?? []
        }
        set {
            var dict = dictionary
            if newValue.isEmpty {
                dict[task.tag] = nil
            } else {
                dict[task.tag] = dict[task.tag] ?? [String: AnyObject]()
                dict[task.tag]?[timestampsKey] = newValue as AnyObject?
            }
            UserDefaults.standard.set(dict, forKey: rootKey)
        }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: rootKey)
    }

}
