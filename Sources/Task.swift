//
//  Task.swift
//  Twice
//
//  Created by Diego Ernst on 9/9/16.
//
//

import Foundation

public protocol Task {

    var tag: String { get }

}

extension String: Task {

    public var tag: String { return self }

}
