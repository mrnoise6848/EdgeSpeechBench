import XCTest

final class EdgeSpeechBenchUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }
    @MainActor func testBenchmarkControlsAndHistory() throws {
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launch()
        let runButton = app.buttons["runBenchmark"]
        if !runButton.exists { app.swipeUp() }
        XCTAssertTrue(runButton.waitForExistence(timeout: 10))
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Benchmark screen (simulator; no fabricated results)"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        XCTAssertTrue(app.staticTexts["benchmarkStatus"].exists)
        let history = app.buttons["Benchmark History"]
        app.swipeUp()
        XCTAssertTrue(history.waitForExistence(timeout: 5))
        history.tap()
        XCTAssertTrue(app.navigationBars["Benchmark History"].waitForExistence(timeout: 5))
    }
    @MainActor func testModelInformationAndPrivacy() throws {
        XCUIDevice.shared.orientation = .portrait
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
