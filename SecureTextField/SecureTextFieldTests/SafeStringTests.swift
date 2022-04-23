//
//  SafeStringTests.swift
//  SecureTextFieldTests
//
//  Created by hanwe on 2022/04/23.
//

import XCTest
@testable import SecureTextField

class SafeStringTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {
        let safeString: NSMutableString.SafeString = NSMutableString.SafeString.makeSafeString("hello")
        let some = safeString.last()
        print("some: \(some)")
    }

}
