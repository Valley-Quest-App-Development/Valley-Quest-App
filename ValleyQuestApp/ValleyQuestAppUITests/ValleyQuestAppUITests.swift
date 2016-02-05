//
//  ValleyQuestAppUITests.swift
//  ValleyQuestAppUITests
//
//  Created by John Kotz on 9/29/15.
//  Copyright © 2015 John Kotz. All rights reserved.
//

import XCTest

class ValleyQuestAppUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicUI() {
        XCTAssert(app.staticTexts["Quests"].exists)
    }
    
    func testQuests() {
        let qname = "Amphitheater Quest"
        XCTAssert(app.staticTexts[qname].exists)
        app.staticTexts[qname].tap()
        XCTAssert(app.staticTexts[qname].exists)
        XCTAssert(app.buttons["More Info"].exists)
        XCTAssert(app.buttons["Clues"].exists)
        XCTAssert(app.buttons["Start Quest"].exists)
        
        app.buttons["Clues"].tap()
        XCTAssert(app.staticTexts["Clues - \(qname)"].exists)
    }
    
}
