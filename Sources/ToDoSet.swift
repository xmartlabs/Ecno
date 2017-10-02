//
//  ToDoSet.swift
//  Ecno
//
//  Created by Diego Ernst on 9/12/16.
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

class ToDoSet {

    fileprivate let infoKey = "info"
    fileprivate let scopeKey = "scope"
    fileprivate let rootKey: String
    fileprivate var dictionary: [String: [String: AnyObject]] {
        get {
            guard let dict = UserDefaults.standard.dictionary(forKey: rootKey) as? [String: [String: AnyObject]] else {
                let dict = [String: [String: AnyObject]]()
                UserDefaults.standard.set(dict, forKey: rootKey)
                return dict
            }
            return dict
        }
        set {
            UserDefaults.standard.set(newValue, forKey: rootKey)
        }
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
        dictionary = set
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
        dictionary = set
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: rootKey)
    }

    func clearExpiredData() {
        // remove 'to do' tasks with scope == .until if it's expired
        var filtered = dictionary
        filtered.forEach { (arg) in
            let (key, value) = arg
            switch Scope.fromDictionary(value[scopeKey] as? [AnyHashable: Any] ?? [:]) {
            case let .some(.until(time)) where time.timeInterval < 0:
                filtered.removeValue(forKey: key)
            default:
                break
            }
        }
        dictionary = filtered
    }

}
