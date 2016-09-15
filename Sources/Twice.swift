//
//  Twice.swift
//  Twice
//
//  Created by Diego Ernst on 9/9/16.
//
//

import Foundation

public class Twice {

    public struct Constants {

        static let appVersionKey = "com.xmartlabs.Twice.AppVersion"
        static let timestampsRootKey = "com.xmartlabs.Twice.Timestamps"
        static let toDoRootKey = "com.xmartlabs.Twice.ToDo"
        static let lastAppUpdateKey = "com.xmartlabs.Twice.LastAppUpdateTime"
        static let bundleShortVersionKey = "CFBundleShortVersionString"
        static let bundleVersionKey = "CFBundleVersion"

    }

    fileprivate static var lastAppUpdatedTime: Date!
    fileprivate static var sessionStartTime: Date!
    fileprivate static var timestampsDictionary = TimestampsDictionary(rootKey: Constants.timestampsRootKey)
    fileprivate static var toDoSet = ToDoSet(rootKey: Constants.toDoRootKey)

    /**
     Initializer method. It must be called before start using any Twice method.
     */
    public static func initialize() {
        let userDefaults = UserDefaults.standard
        let currentAppVersion = appVersion()
        let userDefaultsAppVersion = userDefaults.string(forKey: Constants.appVersionKey)
        if currentAppVersion != userDefaultsAppVersion {
            userDefaults.set(Date(), forKey: Constants.lastAppUpdateKey)
            userDefaults.set(currentAppVersion, forKey: Constants.appVersionKey)
        }
        lastAppUpdatedTime = userDefaults.object(forKey: Constants.lastAppUpdateKey) as! Date
        sessionStartTime = Date()
        toDoSet.clearExpiredData()
    }

    /**
     Marks a task as 'to do' within a given scope, if it has already been marked as to do or been done
     within that scope then it will not be marked. If the scope is nil, then it will be marked as to do
     anyways.

     - parameter task:  Task to be marked as to do.
     - parameter scope: The scope to not repeat the to do task in.
     - parameter info: Additional info for the to do task.
     */
    public static func toDo(_ task: Task, scope: Scope? = nil, info: [AnyHashable: Any]? = nil) {
        guard let scope = scope else {
            toDoSet.add(task, scope: .appInstall, withInfo: info)
            return
        }
        guard let lastTimestamp = timestampsDictionary[task.tag].last else {
            toDoSet.add(task, scope: scope, withInfo: info)
            return
        }
        if !isScope(scope, containing: lastTimestamp) {
            toDoSet.add(task, scope: scope, withInfo: info)
        }
    }

    /**
     Checks if a task is currently marked as 'to do'.

     - parameter task: Task to check.

     - returns: Whether or not the task needs to be done.
     */
    public static func needToDo(_ task: Task) -> Bool {
        return toDoSet.getDataForTask(task).map { isScope($0.scope, containing: Date()) } ?? false
    }

    /**
     Gets the info associated with a 'to do' task.

     - parameter task: The task to get the info from.

     - returns: The info of the 'to do' task if it exists.
     */
    public static func infoForToDo(_ task: Task) -> [AnyHashable: Any]? {
        return toDoSet.getDataForTask(task)?.info
    }

    /**
     Last done timestamp for a given task.

     - parameter task: Task to check its last done timestamp.

     - returns: The task's last timestamp or `nil` if it does not exist.
     */
    public static func lastDone(_ task: Task) -> Date? {
        return timestampsDictionary[task].last
    }

    /**
     Checks if a task has been done.

     - parameter task:          The task to check.
     - parameter scope:         The scope in which to check whether the task has been done.
     - parameter numberOfTimes: How many times the operation must have been done.

     - returns: Whether or not the task has been done within the given constraints.
     */
    public static func beenDone(_ task: Task, scope: Scope = .appInstall, numberOfTimes: CountChecker = .moreThan(0)) -> Bool {
        let timestamps = timestampsDictionary[task]
        let dateInScope = filterDateInScope(scope)
        return !timestamps.isEmpty && numberOfTimes.check(timestamps.filter(dateInScope).count)
    }

    /**
     Marks a task as done.

     - parameter task: The task to mark as done.
     */
    public static func markDone(_ task: Task) {
        timestampsDictionary[task] = timestampsDictionary[task] + [Date()]
        toDoSet.remove(task)
    }

    /**
     Clears all 'done' marks for a given task.

     - parameter task: The task to be cleared.
     */
    public static func clearDone(_ task: Task) {
        timestampsDictionary[task] = []
    }

    /**
     Removes a task from its 'to do' state.

     - parameter task: The task to be removed from 'to do'.
     */
    public static func clearToDo(_ task: Task) {
        toDoSet.remove(task)
    }

    /**
     Clears all 'done' marks for all tasks.
     */
    public static func clearDoneTasks() {
        timestampsDictionary.clear()
    }

    /**
     Removes all tasks from their 'to do' state.
     */
    public static func clearToDoTasks() {
        toDoSet.clear()
    }

    /**
     Clear all 'done' and 'to do' tasks.
     */
    public static func clearAll() {
        clearDoneTasks()
        clearToDoTasks()
    }

}

// MARK: - Helpers

extension Twice {

    fileprivate static func filterDateInScope(_ scope: Scope) -> (Date) -> Bool {
        return { self.isScope(scope, containing: $0) }
    }

    fileprivate static func isScope(_ scope: Scope, containing date: Date) -> Bool {
        switch scope {
        case .appInstall:
            return true
        case .appVersion:
            return date >= lastAppUpdatedTime
        case .appSession:
            return date >= sessionStartTime
        case let .since(time):
            let now = Date()
            return date >= now.addingTimeInterval(-time.timeInterval)
        case let .until(time):
            return date <= Date().addingTimeInterval(time.timeInterval)
        }
    }

    fileprivate static func appVersion() -> String {
        let nsVersion = Bundle.main.infoDictionary?[Constants.bundleShortVersionKey]
        let nsBuild = Bundle.main.infoDictionary?[Constants.bundleVersionKey]

        guard let version = nsVersion as? String, let build = nsBuild as? String else {
            return "0.0.0"
        }

        return "\(version)_\(build)"
    }

}
