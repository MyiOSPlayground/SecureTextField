//
//  SafeString.swift
//  SecureTextField
//
//  Created by hanwe on 2022/04/23.
//

import UIKit

extension NSMutableString {
    typealias SafeString = NSMutableString
    
    static func makeSafeString(_ inputed: NSMutableString) -> SafeString {
        let encoding = String.Encoding.utf8.rawValue
        
        let bufferSize = inputed.maximumLengthOfBytes(using: encoding) + 1
        let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: bufferSize)
        inputed.getCString(buffer, maxLength: bufferSize, encoding: encoding)
        let newString = NSMutableString(
            bytesNoCopy: buffer,
            length: strlen(buffer),
            encoding: encoding,
            freeWhenDone: false
        ) ?? NSMutableString()
        
        DeallocHoocker.install(to: newString, {
            memset(buffer, 0, bufferSize)
            buffer.deallocate()
        })
        
        return newString
    }
    
    static func + (lhs: SafeString, rhs: SafeString) -> SafeString {
        let appended = NSMutableString.init(format: "%@%@", lhs, rhs)
        return makeSafeString(appended)
    }
    
    static func += (lhs: inout SafeString, rhs: SafeString) {
        let appended = NSMutableString.init(format: "%@%@", lhs, rhs)
        lhs = makeSafeString(appended)
    }
    
    static func += (lhs: inout SafeString, rhs: String) {
        let appended = NSMutableString.init(format: "%@%@", lhs, rhs)
        lhs = makeSafeString(appended)
    }
    
    func isEmpty() -> Bool {
        return self.length == 0 ? true : false
    }
    
    func count() -> Int {
        return self.length
    }
    
    func last() -> SafeString {
        let some = self.character(at: self.length-1)
        Character(unicodeScalarLiteral: .init)
        return ""
    }
    
    func removeLast() {
        
    }
}

fileprivate final class DeallocHoocker {
    typealias Handler = () -> Void
    private struct AssociatedKey {
        static var deallocHoocker = "deallocHoocker"
    }
    private let handler: Handler
    private init(_ handler: @escaping Handler) {
        self.handler = handler
    }
    deinit { handler() }
    static func install(to object: AnyObject, _ handler: @escaping Handler) {
        objc_setAssociatedObject(
            object,
            &AssociatedKey.deallocHoocker,
            DeallocHoocker(handler),
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}
