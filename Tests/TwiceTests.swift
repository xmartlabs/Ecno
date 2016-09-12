//
//  TwiceTests.swift
//  TwiceTests
//
//  Copyright © 2016 Xmartlabs SRL. All rights reserved.
//

import XCTest
@testable import Twice

class TwiceTests: XCTestCase {

    fileprivate let task = "testTask"

    override func setUp() {
        super.setUp()
        Twice.initialize()
    }

    override func tearDown() {
        super.tearDown()
        Twice.clearAll()
    }

    func testUnseenTags() {
        Twice.clearAll()
        XCTAssertFalse(Twice.beenDone(task, scope: .appSession))
        XCTAssertFalse(Twice.beenDone(task, scope: .appInstall))
        XCTAssertFalse(Twice.beenDone(task, scope: .appVersion))
        XCTAssertFalse(Twice.beenDone(task, scope: .since(1.days)))
    }

    func testSeenTagImmediately() {
        Twice.markDone(task)
        print(UserDefaults.standard.dictionaryRepresentation())
        XCTAssert(Twice.beenDone(task, scope: .appSession))
        XCTAssert(Twice.beenDone(task, scope: .appInstall))
        XCTAssert(Twice.beenDone(task, scope: .since(1.minutes)))
    }

    func testRemoveFromDone() {
        Twice.markDone(task)
        Twice.clearDone(task)

        XCTAssertFalse(Twice.beenDone(task, scope: .appSession))
        XCTAssertFalse(Twice.beenDone(task, scope: .appInstall))
        XCTAssertFalse(Twice.beenDone(task, scope: .appVersion))
        XCTAssertFalse(Twice.beenDone(task, scope: .since(1.days)))
    }

    func testRemoveFromToDo() {
        Twice.toDo(task)
        XCTAssert(Twice.needToDo(task))
        Twice.clearToDo(task)
        XCTAssertFalse(Twice.beenDone(task, scope: .appSession))
        XCTAssertFalse(Twice.beenDone(task, scope: .appInstall))
        XCTAssertFalse(Twice.beenDone(task, scope: .appVersion))
        XCTAssertFalse(Twice.beenDone(task, scope: .since(1.days)))
    }

    func simulateAppUpdate() {
        UserDefaults.standard.set("another_version", forKey: Twice.Constants.appVersionKey)
        Twice.initialize()
    }

    func testSeenTagAfterAppUpdate() {
        Twice.markDone(task)
        simulateAppUpdate() // this starts a new session

        XCTAssertFalse(Twice.beenDone(task, scope: .appSession))
        XCTAssert(Twice.beenDone(task, scope: .appInstall))
        XCTAssertFalse(Twice.beenDone(task, scope: .appVersion))
        XCTAssert(Twice.beenDone(task, scope: .since(1.minutes)))
    }

    func testSeenTagAfterSecond() {
        Twice.markDone(task)

        XCTAssert(Twice.beenDone(task, scope: .appSession))
        XCTAssert(Twice.beenDone(task, scope: .appInstall))
        XCTAssert(Twice.beenDone(task, scope: .appVersion))

        usleep(1001 * 1000)
        XCTAssertFalse(Twice.beenDone(task, scope: .since(1.seconds)))
    }

    func testClearAll() {
        let task1 = "task1"
        let task2 = "task2"
        Twice.markDone(task1)
        Twice.markDone(task2)
        Twice.clearAll()

        [task1, task2].forEach {
            XCTAssertFalse(Twice.beenDone($0, scope: .appSession))
            XCTAssertFalse(Twice.beenDone($0, scope: .appInstall))
            XCTAssertFalse(Twice.beenDone($0, scope: .appVersion))
            XCTAssertFalse(Twice.beenDone($0, scope: .since(1.seconds)))
        }
    }

    func testClearAllDoneAndTodos() {
        let t1 = "t1"
        let t2 = "t2"
        Twice.toDo(t1)
        Twice.markDone(t2)
        XCTAssert(Twice.needToDo(t1))
        XCTAssert(Twice.beenDone(t2))

        Twice.clearAll()
        XCTAssertFalse(Twice.needToDo(t1))
        XCTAssertFalse(Twice.beenDone(t2))
    }

    func testTodo() {
        let task1 = "todo task"
        XCTAssertFalse(Twice.needToDo(task1))
        XCTAssertFalse(Twice.beenDone(task1))

        Twice.toDo(task1)
        XCTAssert(Twice.needToDo(task1))
        XCTAssertFalse(Twice.beenDone(task1))

        Twice.markDone(task1)
        XCTAssertFalse(Twice.needToDo(task1))
        XCTAssert(Twice.beenDone(task1))
        XCTAssert(Twice.beenDone(task1, scope: .since(1.seconds)))
    }

    func testRepeatingToDos() {
        let t = "repeating to do task"
        Twice.toDo(t)
        XCTAssert(Twice.needToDo(t))
        Twice.markDone(t)
        Twice.toDo(t)
        XCTAssert(Twice.needToDo(t))
    }

    func testTodoThisSession() {
        let t = "to do this session task"

        Twice.toDo(t, scope: .appSession)
        XCTAssert(Twice.needToDo(t))
        XCTAssertFalse(Twice.beenDone(t))

        Twice.markDone(t)
        XCTAssertFalse(Twice.needToDo(t))
        XCTAssert(Twice.beenDone(t))

        Twice.toDo(t, scope: .appSession)
        XCTAssertFalse(Twice.needToDo(t))

        Twice.toDo(t)
        XCTAssert(Twice.needToDo(t))
    }

    func testTodoThisInstall() {
        let t = "to do this install task"

        Twice.toDo(t, scope: .appInstall)
        XCTAssert(Twice.needToDo(t))
        XCTAssertFalse(Twice.beenDone(t))

        Twice.markDone(t)
        XCTAssertFalse(Twice.needToDo(t))
        XCTAssert(Twice.beenDone(t))

        Twice.toDo(t, scope: .appInstall)
        XCTAssertFalse(Twice.needToDo(t))

        Twice.toDo(t)
        XCTAssert(Twice.needToDo(t))
    }

    func testTodoThisAppVersion() {
        let t = "todo this app version task"

        Twice.toDo(t, scope: .appVersion)
        XCTAssert(Twice.needToDo(t))
        XCTAssertFalse(Twice.beenDone(t))

        Twice.markDone(t)
        XCTAssertFalse(Twice.needToDo(t))
        XCTAssert(Twice.beenDone(t))

        Twice.toDo(t, scope: .appVersion)
        XCTAssertFalse(Twice.needToDo(t))

        simulateAppUpdate()

        Twice.toDo(t, scope: .appVersion)
        XCTAssert(Twice.needToDo(t))

        Twice.toDo(t)
        XCTAssert(Twice.needToDo(t))
    }

    func testEmptyTag() {
        let emptyTag = ""
        XCTAssertFalse(Twice.beenDone(emptyTag))
        Twice.markDone(emptyTag)
        XCTAssert(Twice.beenDone(emptyTag))
    }

    func testBeenDoneMultipleTimes() {
        let t = "action done several times"
        Twice.markDone(t)
        Twice.markDone(t)
        XCTAssertFalse(Twice.beenDone(t, numberOfTimes: .equal(3)))
        Twice.markDone(t)
        XCTAssert(Twice.beenDone(t, numberOfTimes: .equal(3)))
    }

    func testBeenDoneMultipleTimesAcrossScopes() {
        let t = "action done several times in different scopes"
        Twice.markDone(t)
        simulateAppUpdate()
        sleep(1)
        Twice.markDone(t)

        XCTAssert(Twice.beenDone(t, scope: .appInstall, numberOfTimes: .equal(2)))
        XCTAssertFalse(Twice.beenDone(t, scope: .appVersion, numberOfTimes: .equal(2)))

        Twice.markDone(t)
        XCTAssert(Twice.beenDone(t, scope: .appInstall, numberOfTimes: .equal(3)))
        XCTAssert(Twice.beenDone(t, scope: .appVersion, numberOfTimes: .equal(2)))
    }

    func testBeenDoneDifferentTimeChecks() {
        let t = "test tag"
        Twice.markDone(t)
        Twice.markDone(t)
        Twice.markDone(t)

        XCTAssert(Twice.beenDone(t, numberOfTimes: .moreThan(-1)))
        XCTAssert(Twice.beenDone(t, numberOfTimes: .moreThan(2)))
        XCTAssertFalse(Twice.beenDone(t, numberOfTimes: .moreThan(3)))

        XCTAssert(Twice.beenDone(t, numberOfTimes: .lessThan(10)))
        XCTAssert(Twice.beenDone(t, numberOfTimes: .lessThan(4)))
        XCTAssertFalse(Twice.beenDone(t, numberOfTimes: .lessThan(3)))
    }

    func testBeenDoneMultipleTimesWithTimeStamps() {
        Twice.markDone(task)
        sleep(1)
        Twice.markDone(task)
        XCTAssert(Twice.beenDone(task, scope: .since(3.seconds), numberOfTimes: .equal(2)))
        XCTAssert(Twice.beenDone(task, scope: .since(1.seconds), numberOfTimes: .equal(1)))
    }

    func testLastDoneWhenNeverDone() {
        XCTAssertNil(Twice.lastDone(task))
    }

    func testLastDone() {
        Twice.markDone(task)
        let lastDone = Twice.lastDone(task)
        XCTAssertNotNil(lastDone)
        XCTAssert(Date().timeIntervalSince1970 - lastDone!.timeIntervalSince1970 < 0.01)
    }

    func testLastDoneMultipleDates() {
        Twice.markDone(task)
        usleep(1000 * 100)
        Twice.markDone(task)
        let lastDone = Twice.lastDone(task)
        XCTAssertNotNil(lastDone)
        XCTAssert(Date().timeIntervalSince1970 - lastDone!.timeIntervalSince1970 < 0.01)
    }

    func testToDoWithInfo() {
        Twice.toDo(task, info: ["key": 4])
        XCTAssert(Twice.needToDo(task))
        let info = Twice.infoForToDo(task) as? [String: Int]
        XCTAssertNotNil(info)
        XCTAssert(info! == ["key": 4])
    }

    func testToDoWithEmptyInfo() {
        Twice.toDo(task)
        XCTAssert(Twice.needToDo(task))
        XCTAssertNil(Twice.infoForToDo(task))
        Twice.clearToDo(task)
        Twice.toDo(task, info: [:])
        XCTAssert(Twice.needToDo(task))
        XCTAssert(Twice.infoForToDo(task)?.isEmpty == true)
    }

    func testToDoUntil() {
        Twice.toDo(task, scope: .until(0.5.seconds))
        XCTAssert(Twice.needToDo(task))
        sleep(1)
        XCTAssertFalse(Twice.needToDo(task))
    }
    
    func testToDoUntil2() {
        Twice.toDo(task, scope: .until(2.seconds))
        XCTAssert(Twice.needToDo(task))
        Twice.markDone(task)
        XCTAssertFalse(Twice.needToDo(task))
    }

    func testToDoSince() {
        Twice.toDo(task, scope: .since(1.seconds))
        XCTAssert(Twice.needToDo(task))
        Twice.markDone(task)
        XCTAssertFalse(Twice.needToDo(task))
    }
    
    func testToDoSince2() {
        Twice.markDone(task)
        sleep(1)
        Twice.toDo(task, scope: .since(3.seconds))
        XCTAssertFalse(Twice.needToDo(task))
    }

}
