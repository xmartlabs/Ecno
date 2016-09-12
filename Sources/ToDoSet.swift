//
//  ToDoSet.swift
//  Twice
//
//  Created by Diego Ernst on 9/12/16.
//
//

import Foundation

class ToDoSet {

    private let infoKey = "info"
    private let scopeKey = "scope"
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

    func add(_ task: Task, scope: Scope, withInfo info: [AnyHashable: Any]? = nil) {
        var set = dictionary
        var dict: [String: AnyObject] = [scopeKey: scope.toDictionary() as AnyObject]
        if let info = info {
            dict[infoKey] = info as AnyObject?
        }
        set[task.tag] = dict
        UserDefaults.standard.set(set, forKey: rootKey)
    }

    func getDataForTask(_ task: Task) -> (scope: Scope, info: [AnyHashable: Any]?)? {
        let dict = dictionary
        guard let taskDict = dict[task.tag] else { return nil }
        guard let scope = Scope.fromDictionary(taskDict[scopeKey] as? [AnyHashable: Any] ?? [:]) else { return nil }
        let info = taskDict[infoKey] as? [AnyHashable: Any]
        return (scope: scope, info: info)
    }

    func remove(_ task: Task) {
        var set = dictionary
        set[task.tag] = nil
        UserDefaults.standard.set(set, forKey: rootKey)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: rootKey)
    }

    func clearExpiredData() {
        // remove 'to do' tasks with scope == .Until if it's expired
        let set = dictionary.filter { key, value in
            guard let scope = Scope.fromDictionary(value[scopeKey] as? [AnyHashable: Any] ?? [:]) else { return false }
            if case let Scope.until(time) = scope {
                return time.timeInterval >= 0
            }
            return false
        }
        UserDefaults.standard.set(set, forKey: rootKey)
    }

}
