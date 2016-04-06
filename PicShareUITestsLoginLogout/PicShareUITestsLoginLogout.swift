//
//  PicShareUITestslogin.swift
//  PicShareUITestslogin
//
//  Created by Joseph Mouawad on 4/4/16.
//  Copyright © 2016 USC. All rights reserved.
//

import XCTest

class PicShareUITestslogin: XCTestCase {
    
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
    
    
    func testvalidLogin() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let app = XCUIApplication()
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        
        let usernameTextField = elementsQuery.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("joe")
        
        let passwordSecureTextField = elementsQuery.secureTextFields["Password"]
        passwordSecureTextField.tap()
        
        let moreNumbersKey = app.keys["more, numbers"]
        moreNumbersKey.tap()
        passwordSecureTextField.typeText("123456")
        elementsQuery.buttons["Log In"].tap()
        
    }
    
    func test"logout(){
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        app.buttons["Log Out"].tap()
        
        let yesButton = app.alerts.collectionViews.buttons["Yes"]
        yesButton.tap()
    }
    func testlogoutCancel(){
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        app.buttons["Log Out"].tap()
        
        let noButton = app.alerts.collectionViews.buttons["No"]
        noButton.tap()
    }
    
    
    func testInvalidPass(){
        let app = XCUIApplication()
        let elementsQuery = app.scrollViews.otherElements
        let usernameTextField = elementsQuery.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("joe")
        
        let passwordSecureTextField = elementsQuery.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("joejoejoe")
        elementsQuery.buttons["Log In"].tap()
        
        let okButton = app.alerts["Error"].collectionViews.buttons["OK"]
        okButton.tap()
    }
    func testInvalidUser(){
        
        
        let app = XCUIApplication()
        let elementsQuery = app.scrollViews.otherElements
        let usernameTextField = elementsQuery.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("jjk")
        app.keys["k"].tap()
        usernameTextField.typeText("kk")
        
        let passwordSecureTextField = elementsQuery.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("joejoejoe")
        
        elementsQuery.buttons["Log In"].tap()
        app.alerts["Error"].collectionViews.buttons["OK"].tap()
    }
    
    func testNoUser(){
        let app = XCUIApplication()
        let elementsQuery = app.scrollViews.otherElements
        let passwordSecureTextField = elementsQuery.secureTextFields["Password"]
        passwordSecureTextField.tap()
        
        let moreNumbersKey = app.keys["more, numbers"]
        moreNumbersKey.tap()
        passwordSecureTextField.typeText("123456")
        elementsQuery.buttons["Log In"].tap()
        app.alerts["Error"].collectionViews.buttons["OK"].tap()
        passwordSecureTextField.tap()
    }
    
    func testNoPass(){
        let app = XCUIApplication()
        let elementsQuery = app.scrollViews.otherElements
        let usernameTextField = elementsQuery.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("joe")
        elementsQuery.buttons["Log In"].tap()
        app.alerts["Error"].collectionViews.buttons["OK"].tap()
        usernameTextField.tap()
    }
    
    func testNoPassNoUser(){
        
        let app = XCUIApplication()
        app.scrollViews.otherElements.buttons["Log In"].tap()
        
        let okButton = app.alerts["Error"].collectionViews.buttons["OK"]
        okButton.tap()
    }
    
    
}
