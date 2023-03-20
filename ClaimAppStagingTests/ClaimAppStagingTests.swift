//
//  ClaimAppStagingTests.swift
//  ClaimAppStagingTests
//
//  Created by wanggao on 2023/3/15.
//

import XCTest
@testable import ClaimAppStaging

final class ClaimAppStagingTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        let invalidEmail1 = "123@126.com"
        let result1 = invalidEmail1.isEmail
        XCTAssertFalse(result1, "Positive result for invalid email")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
