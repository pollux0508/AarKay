// Inspired by the Carthage library:
// https://github.com/Carthage/Carthage
/*
 The MIT License (MIT)

 Copyright (c) 2014 Carthage contributors

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

/// A queue to print all logs on console asynchrously.
private let outputQueue = { () -> DispatchQueue in
    let targetQueue = DispatchQueue.global(qos: .userInitiated)
    let queue = DispatchQueue(
        label: "me.RahulKatariya.AarKay.outputQueue",
        target: targetQueue
    )
    #if !os(Linux)
    atexit_b { queue.sync(flags: .barrier) {} }
    #endif
    return queue
}()

/// A thread-safe version of Swift's standard println().
internal func println() {
    outputQueue.async {
        Swift.print()
    }
}

/// A thread-safe version of Swift's standard println().
internal func println<T>(_ object: T) {
    outputQueue.async {
        Swift.print(object)
    }
}

/// A thread-safe version of Swift's standard print().
internal func print<T>(_ object: T) {
    outputQueue.async {
        Swift.print(object, terminator: "")
    }
}
