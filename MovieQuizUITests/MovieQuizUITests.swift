import XCTest


class MovieQuizUITests: XCTestCase {
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
    
    
    func testButtons() {
        let buttons = ["Yes", "No"]
        sleep(3)
        
        for (index, button) in buttons.enumerated() {
            
            let firstPoster = app.images["Poster"]
            let firstPosterData = firstPoster.screenshot().pngRepresentation
            
            app.buttons[button].tap()
            sleep(3)
            
            let secondPoster = app.images["Poster"]
            let secondPosterData = secondPoster.screenshot().pngRepresentation
            
            XCTAssertNotEqual(firstPosterData, secondPosterData)
            
            let indexLabel = app.staticTexts["Index"]
            XCTAssertEqual(indexLabel.label,"\(index+2)/10")
        }
    }

}
