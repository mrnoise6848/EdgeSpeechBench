import XCTest

final class EdgeSpeechBenchUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    @MainActor func testBenchmarkControlsAndHistory() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["runBenchmark"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["benchmarkStatus"].exists)
        let history = app.buttons["Benchmark History"]
        app.swipeUp()
        XCTAssertTrue(history.waitForExistence(timeout: 5))
        history.tap()
        XCTAssertTrue(app.navigationBars["Benchmark History"].waitForExistence(timeout: 5))
    }
    @MainActor func testModelInformationAndPrivacy() throws {
        let app = XCUIApplication()
        app.launch()
        app.swipeUp()
        let privacy = app.buttons["Privacy and local data"]
        XCTAssertTrue(privacy.waitForExistence(timeout: 5))
        privacy.tap()
        XCTAssertTrue(app.navigationBars["Privacy"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Local processing"].exists)
    }
}
