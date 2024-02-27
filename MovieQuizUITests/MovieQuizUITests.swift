import XCTest


final class MovieQuizUITests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label,"2/10")
    }
    
    func testNoButton() {
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label,"2/10")
    }

    func testAlertAtTheEndOfRound() {
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        XCTAssertEqual(1, app.alerts.count)
    
        let alert = app.alerts["Этот раунд окончен!"]
    
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons["Сыграем еще раз?"].label, "Сыграем еще раз?")
    }
    
    func testGameRestart() {
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
    
        let alert = app.alerts["Этот раунд окончен!"]
        alert.buttons["Сыграем еще раз?"].tap()
        
        sleep(1)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label,"1/10")
    
        XCTAssertFalse(alert.exists)
    }
}
