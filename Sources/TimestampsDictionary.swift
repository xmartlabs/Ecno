//
//  TimestampsDictionary.swift
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

class TimestampsDictionary {

    fileprivate let timestampsKey = "timestamps"
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
            dictionary = dict
        }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: rootKey)
    }

}
