# Twice

<p align="left">
<a href="https://travis-ci.org/dernster/Twice"><img src="https://travis-ci.org/dernster/Twice.svg?branch=master" alt="Build status" /></a>
<img src="https://img.shields.io/badge/platform-iOS-blue.svg?style=flat" alt="Platform iOS" />
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift3-compatible-4BC51D.svg?style=flat" alt="Swift 3 compatible" /></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
<a href="https://cocoapods.org/pods/XLActionController"><img src="https://img.shields.io/badge/pod-1.0.0-blue.svg" alt="CocoaPods compatible" /></a>
<a href="https://raw.githubusercontent.com/dernster/Twice/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" /></a>
</p>

By [Xmartlabs SRL](https://xmartlabs.com/).

## Inroduction

**Twice** was inspired by [Once](https://github.com/jonfinerty/Once) Android library. It's a tasks manager abstraction that allows you to mark 'tasks' as done, 'to-do' and check for those states.  

**Twice** is ideal for:
* Show tutorials once within the application.
* Perform certain task periodically.
* Trigger a task based on a user action.


## Usage

First you need to initialize it:

```swift
Twice.initialize()
```
> Note: you should initialize it when your app gets launched.

Then, you can check whether a task was done by:
```swift
if !Twice.beenDone("task") {
  //...
  Twice.markDone("task")
}
```

Also, you can check for specific requirements about a certain task:
```swift
if Twice.beenDone("task", scope: .appSession, numberOfTimes: .moreThan(3)) {
  // do stuff
}
```
or
```swift
if Twice.beenDone("task", scope: .since(20.minutes), numberOfTimes: .lessThan(3)) {
  // do stuff
}
```
Additionally, you can program a 'to do' task by:
```swift
Twice.toDo("show banner", scope: .until(3.hours), info: ["name": "bannerName"])
```
and then query if you need to do that task:
```swift
if Twice.needToDo("show banner") {
  let info = Twice.infoForToDo("show banner") // ["name": "bannerName"]
  // ...
}
```


## Task

Any type conforming to the `Task` protocol. Since it would be the most common case, the `String` type already conforms to `Task`.

```swift
public protocol Task {

    var tag: String { get }

}
```


## Scope

Scopes represents periods of time within the application.

* `.appInstall`  
This period represents all times for the application.
* `.appVersion`  
Period starting when the current version of the app was installed.
* `.appSession`  
Period starting when the application was launched.
* `.since(TimeInterval)`  
Period starting since `TimeInterval` time ago from now. For instance, `.since(2.days)`
* `.until(TimeInterval)`  
Period valid until `TimeInterval` from now. For instance, `.until(3.hours)`. This should be useful to set a 'to do' task that expires.

## Functions

* `func toDo(_ task: Task, scope: Scope? = nil, info: [AnyHashable: Any]? = nil)`  
Marks a task as 'to do' within a given scope, if it has already been marked as to do or been done within that scope then it will not be marked. If the scope is nil, then it will be marked as to do anyways.
* `func needToDo(_ task: Task) -> Bool`  
Checks if a task is currently marked as 'to do'.
* `func infoForToDo(_ task: Task) -> [AnyHashable: Any]?`  
Gets the info associated with a 'to do' task. (only if you provided it in the `toDo(...)` function)
* `func lastDone(_ task: Task) -> Date?`  
Last done timestamp for a given task.
* `func beenDone(_ task: Task, scope: Scope = .appInstall, numberOfTimes: CountChecker = .moreThan(0)) -> Bool`  
Checks if a task has been done with the given requirements.
* `func markDone(_ task: Task)`  
Marks a task as done.



## Requirements

* iOS 8.0+
* Xcode 8.0+

## Getting involved

* If you **want to contribute** please feel free to **submit pull requests**.
* If you **have a feature request** please **open an issue**.
* If you **found a bug** or **need help** please **check older issues**

Before contribute check the [CONTRIBUTING](https://github.com/dernster/Twice/blob/master/CONTRIBUTING.md) file for more info.

If you use **Twice** in your app We would love to hear about it! Drop us a line on [twitter](https://twitter.com/dernster).

## Examples

Follow these 3 steps to run Example project:

* Clone Twice repository
* Open Twice workspace and run the *Example* project.

## Installation

#### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects.

To install Twice, simply add the following line to your Podfile:

```ruby
pod 'Twice', '~> 1.0'
```

#### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a simple, decentralized dependency manager for Cocoa.

To install Twice, simply add the following line to your Cartfile:

```ogdl
github "xmartlabs/Twice" ~> 1.0
```

## Author

* [Diego Ernst](https://github.com/dernster)

# Change Log

This can be found in the [CHANGELOG.md](CHANGELOG.md) file.
