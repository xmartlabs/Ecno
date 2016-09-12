//
//  EcnoTests.swift
//  EcnoTests
//
//  Copyright © 2016 Xmartlabs SRL. All rights reserved.
//

import XCTest
@testable import Ecno

class EcnoTests: XCTestCase {

    fileprivate let task = "testTask"

    override func setUp() {
        super.setUp()
        Ecno.initialize()
    }

    override func tearDown() {
        super.tearDown()
        Ecno.clearAll()
    }

    func testUnseenTags() {
        Ecno.clearAll()
        XCTAssertFalse(Ecno.beenDone(task, scope: .appSession))
        XCTAssertFalse(Ecno.beenDone(task, scope: .appInstall))
        XCTAssertFalse(Ecno.beenDone(task, scope: .appVersion))
        XCTAssertFalse(Ecno.beenDone(task, scope: .since(1.days)))
    }

    func testSeenTagImmediately() {
        Ecno.markDone(task)
        print(UserDefaults.standard.dictionaryRepresentation())
        XCTAssert(Ecno.beenDone(task, scope: .appSession))
        XCTAssert(Ecno.beenDone(task, scope: .appInstall))
        XCTAssert(Ecno.beenDone(task, scope: .since(1.minutes)))
    }

    func testRemoveFromDone() {
        Ecno.markDone(task)
        Ecno.clearDone(task)

        XCTAssertFalse(Ecno.beenDone(task, scope: .appSession))
        XCTAssertFalse(Ecno.beenDone(task, scope: .appInstall))
        XCTAssertFalse(Ecno.beenDone(task, scope: .appVersion))
        XCTAssertFalse(Ecno.beenDone(task, scope: .since(1.days)))
    }

    func testRemoveFromToDo() {
        Ecno.toDo(task)
        XCTAssert(Ecno.needToDo(task))
        Ecno.clearToDo(task)
        XCTAssertFalse(Ecno.beenDone(task, scope: .appSession))
        XCTAssertFalse(Ecno.beenDone(task, scope: .appInstall))
        XCTAssertFalse(Ecno.beenDone(task, scope: .appVersion))
        XCTAssertFalse(Ecno.beenDone(task, scope: .since(1.days)))
    }

    func simulateAppUpdate() {
        UserDefaults.standard.set("another_version", forKey: Ecno.Constants.appVersionKey)
        Ecno.initialize()
    }

    func testSeenTagAfterAppUpdate() {
        Ecno.markDone(task)
        simulateAppUpdate() // this starts a new session

        XCTAssertFalse(Ecno.beenDone(task, scope: .appSession))
        XCTAssert(Ecno.beenDone(task, scope: .appInstall))
        XCTAssertFalse(Ecno.beenDone(task, scope: .appVersion))
        XCTAssert(Ecno.beenDone(task, scope: .since(1.minutes)))
    }

    func testSeenTagAfterSecond() {
        Ecno.markDone(task)

        XCTAssert(Ecno.beenDone(task, scope: .appSession))
        XCTAssert(Ecno.beenDone(task, scope: .appInstall))
        XCTAssert(Ecno.beenDone(task, scope: .appVersion))

        usleep(1001 * 1000)
        XCTAssertFalse(Ecno.beenDone(task, scope: .since(1.seconds)))
    }

    func testClearAll() {
        let task1 = "task1"
        let task2 = "task2"
        Ecno.markDone(task1)
        Ecno.markDone(task2)
        Ecno.clearAll()

        [task1, task2].forEach {
            XCTAssertFalse(Ecno.beenDone($0, scope: .appSession))
            XCTAssertFalse(Ecno.beenDone($0, scope: .appInstall))
            XCTAssertFalse(Ecno.beenDone($0, scope: .appVersion))
            XCTAssertFalse(Ecno.beenDone($0, scope: .since(1.seconds)))
        }
    }

    func testClearAllDoneAndTodos() {
        let t1 = "t1"
        let t2 = "t2"
        Ecno.toDo(t1)
        Ecno.markDone(t2)
        XCTAssert(Ecno.needToDo(t1))
        XCTAssert(Ecno.beenDone(t2))

        Ecno.clearAll()
        XCTAssertFalse(Ecno.needToDo(t1))
        XCTAssertFalse(Ecno.beenDone(t2))
    }

    func testTodo() {
        let task1 = "todo task"
        XCTAssertFalse(Ecno.needToDo(task1))
        XCTAssertFalse(Ecno.beenDone(task1))

        Ecno.toDo(task1)
        XCTAssert(Ecno.needToDo(task1))
        XCTAssertFalse(Ecno.beenDone(task1))

        Ecno.markDone(task1)
        XCTAssertFalse(Ecno.needToDo(task1))
        XCTAssert(Ecno.beenDone(task1))
        XCTAssert(Ecno.beenDone(task1, scope: .since(1.seconds)))
    }

    func testRepeatingToDos() {
        let t = "repeating to do task"
        Ecno.toDo(t)
        XCTAssert(Ecno.needToDo(t))
        Ecno.markDone(t)
        Ecno.toDo(t)
        XCTAssert(Ecno.needToDo(t))
    }

    func testTodoThisSession() {
        let t = "to do this session task"

        Ecno.toDo(t, scope: .appSession)
        XCTAssert(Ecno.needToDo(t))
        XCTAssertFalse(Ecno.beenDone(t))

        Ecno.markDone(t)
        XCTAssertFalse(Ecno.needToDo(t))
        XCTAssert(Ecno.beenDone(t))

        Ecno.toDo(t, scope: .appSession)
        XCTAssertFalse(Ecno.needToDo(t))

        Ecno.toDo(t)
        XCTAssert(Ecno.needToDo(t))
    }

    func testTodoThisInstall() {
        let t = "to do this install task"

        Ecno.toDo(t, scope: .appInstall)
        XCTAssert(Ecno.needToDo(t))
        XCTAssertFalse(Ecno.beenDone(t))

        Ecno.markDone(t)
        XCTAssertFalse(Ecno.needToDo(t))
        XCTAssert(Ecno.beenDone(t))

        Ecno.toDo(t, scope: .appInstall)
        XCTAssertFalse(Ecno.needToDo(t))

        Ecno.toDo(t)
        XCTAssert(Ecno.needToDo(t))
    }

    func testTodoThisAppVersion() {
        let t = "todo this app version task"

        Ecno.toDo(t, scope: .appVersion)
        XCTAssert(Ecno.needToDo(t))
        XCTAssertFalse(Ecno.beenDone(t))

        Ecno.markDone(t)
        XCTAssertFalse(Ecno.needToDo(t))
        XCTAssert(Ecno.beenDone(t))

        Ecno.toDo(t, scope: .appVersion)
        XCTAssertFalse(Ecno.needToDo(t))

        simulateAppUpdate()

        Ecno.toDo(t, scope: .appVersion)
        XCTAssert(Ecno.needToDo(t))

        Ecno.toDo(t)
        XCTAssert(Ecno.needToDo(t))
    }

    func testEmptyTag() {
        let emptyTag = ""
        XCTAssertFalse(Ecno.beenDone(emptyTag))
        Ecno.markDone(emptyTag)
        XCTAssert(Ecno.beenDone(emptyTag))
    }

    func testBeenDoneMultipleTimes() {
        let t = "action done several times"
        Ecno.markDone(t)
        Ecno.markDone(t)
        XCTAssertFalse(Ecno.beenDone(t, numberOfTimes: .equal(3)))
        Ecno.markDone(t)
        XCTAssert(Ecno.beenDone(t, numberOfTimes: .equal(3)))
    }

    func testBeenDoneMultipleTimesAcrossScopes() {
        let t = "action done several times in different scopes"
        Ecno.markDone(t)
        simulateAppUpdate()
        sleep(1)
        Ecno.markDone(t)

        XCTAssert(Ecno.beenDone(t, scope: .appInstall, numberOfTimes: .equal(2)))
        XCTAssertFalse(Ecno.beenDone(t, scope: .appVersion, numberOfTimes: .equal(2)))

        Ecno.markDone(t)
        XCTAssert(Ecno.beenDone(t, scope: .appInstall, numberOfTimes: .equal(3)))
        XCTAssert(Ecno.beenDone(t, scope: .appVersion, numberOfTimes: .equal(2)))
    }

    func testBeenDoneDifferentTimeChecks() {
        let t = "test tag"
        Ecno.markDone(t)
        Ecno.markDone(t)
        Ecno.markDone(t)

        XCTAssert(Ecno.beenDone(t, numberOfTimes: .moreThan(-1)))
        XCTAssert(Ecno.beenDone(t, numberOfTimes: .moreThan(2)))
        XCTAssertFalse(Ecno.beenDone(t, numberOfTimes: .moreThan(3)))

        XCTAssert(Ecno.beenDone(t, numberOfTimes: .lessThan(10)))
        XCTAssert(Ecno.beenDone(t, numberOfTimes: .lessThan(4)))
        XCTAssertFalse(Ecno.beenDone(t, numberOfTimes: .lessThan(3)))
    }

    func testBeenDoneMultipleTimesWithTimeStamps() {
        Ecno.markDone(task)
        sleep(1)
        Ecno.markDone(task)
        XCTAssert(Ecno.beenDone(task, scope: .since(3.seconds), numberOfTimes: .equal(2)))
        XCTAssert(Ecno.beenDone(task, scope: .since(1.seconds), numberOfTimes: .equal(1)))
    }

    func testLastDoneWhenNeverDone() {
        XCTAssertNil(Ecno.lastDone(task))
    }

    func testLastDone() {
        Ecno.markDone(task)
        let lastDone = Ecno.lastDone(task)
        XCTAssertNotNil(lastDone)
        XCTAssert(Date().timeIntervalSince1970 - lastDone!.timeIntervalSince1970 < 0.01)
    }

    func testLastDoneMultipleDates() {
        Ecno.markDone(task)
        usleep(1000 * 100)
        Ecno.markDone(task)
        let lastDone = Ecno.lastDone(task)
        XCTAssertNotNil(lastDone)
        XCTAssert(Date().timeIntervalSince1970 - lastDone!.timeIntervalSince1970 < 0.01)
    }

    func testToDoWithInfo() {
        Ecno.toDo(task, info: ["key": 4])
        XCTAssert(Ecno.needToDo(task))
        let info = Ecno.infoForToDo(task) as? [String: Int]
        XCTAssertNotNil(info)
        XCTAssert(info! == ["key": 4])
    }

    func testToDoWithEmptyInfo() {
        Ecno.toDo(task)
        XCTAssert(Ecno.needToDo(task))
        XCTAssertNil(Ecno.infoForToDo(task))
        Ecno.clearToDo(task)
        Ecno.toDo(task, info: [:])
        XCTAssert(Ecno.needToDo(task))
        XCTAssert(Ecno.infoForToDo(task)?.isEmpty == true)
    }

    func testToDoUntil() {
        Ecno.toDo(task, scope: .until(0.5.seconds))
        XCTAssert(Ecno.needToDo(task))
        sleep(1)
        XCTAssertFalse(Ecno.needToDo(task))
    }

    func testToDoUntil2() {
        Ecno.toDo(task, scope: .until(2.seconds))
        XCTAssert(Ecno.needToDo(task))
        Ecno.markDone(task)
        XCTAssertFalse(Ecno.needToDo(task))
    }

    func testToDoSince() {
        Ecno.toDo(task, scope: .since(1.seconds))
        XCTAssert(Ecno.needToDo(task))
        Ecno.markDone(task)
        XCTAssertFalse(Ecno.needToDo(task))
    }

    func testToDoSince2() {
        Ecno.markDone(task)
        sleep(1)
        Ecno.toDo(task, scope: .since(3.seconds))
        XCTAssertFalse(Ecno.needToDo(task))
    }

    func testExpiredToDo() {
        Ecno.toDo(task, scope: .until(1.9.seconds), info: ["dummy": "info"])
        XCTAssert(Ecno.needToDo(task))
        XCTAssertNotNil(Ecno.infoForToDo(task))
        sleep(2)
        XCTAssertFalse(Ecno.needToDo(task))
        XCTAssertNotNil(Ecno.infoForToDo(task)) // the task is still persisted.
        Ecno.initialize() // should remove the expired task
        XCTAssertFalse(Ecno.needToDo(task))
        XCTAssertNil(Ecno.infoForToDo(task))
    }

}
