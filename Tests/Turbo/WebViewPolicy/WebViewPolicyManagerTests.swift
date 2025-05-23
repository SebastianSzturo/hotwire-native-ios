@testable import HotwireNative
import XCTest
import WebKit

@MainActor
final class WebViewPolicyManagerTests: XCTestCase {
    let navigatorConfiguration = Navigator.Configuration(
        name: "test",
        startLocation: URL(string: "https://my.app.com")!
    )
    let url = URL(string: "https://my.app.com/page")!
    var policyManager: WebViewPolicyManager!
    var webNavigationSimulator: WebViewNavigationSimulator!
    var navigator: Navigator!
    static var navigationAction: WKNavigationAction!

    override func setUp() async throws {
        navigator = Navigator(configuration: navigatorConfiguration)

        // We can't instantiate a `WKNavigationAction`, so we load HTML and retrieve one.
        // In these tests, the navigation action is not actually evaluated, but we need it as an argument
        // when calling `decidePolicy` on the handlers.
        if Self.navigationAction == nil {
            webNavigationSimulator = WebViewNavigationSimulator()
            Self.navigationAction = try await webNavigationSimulator.simulateNavigation(
                withHTML: .simpleLink,
                simulateLinkClickElementId: "link"
            )!
        }
    }

    override func tearDown() async throws {
        webNavigationSimulator = nil
    }

    func test_no_handlers_allows_navigation() async throws {
        policyManager = WebViewPolicyManager(policyDecisionHandlers: [])

        let result = policyManager.decidePolicy(
            for: Self.navigationAction,
            configuration: navigatorConfiguration,
            navigator: navigator
        )

        XCTAssertEqual(result, WebViewPolicyManager.Decision.allow)
    }

    func test_no_matching_handlers_allows_navigation() async throws {
        let noMatchSpy1 = NoMatchWebViewPolicyDecisionHandler()
        let noMatchSpy2 = NoMatchWebViewPolicyDecisionHandler()

        policyManager = WebViewPolicyManager(
            policyDecisionHandlers: [
                noMatchSpy1,
                noMatchSpy2
            ]
        )

        let result = policyManager.decidePolicy(
            for: Self.navigationAction,
            configuration: navigatorConfiguration,
            navigator: navigator
        )

        XCTAssertTrue(noMatchSpy1.matchesWasCalled)
        XCTAssertFalse(noMatchSpy1.handleWasCalled)
        XCTAssertTrue(noMatchSpy2.matchesWasCalled)
        XCTAssertFalse(noMatchSpy2.handleWasCalled)
        XCTAssertEqual(result, WebViewPolicyManager.Decision.allow)
    }

    func test_only_first_matching_handler_is_executed() async throws {
        let noMatchSpy = NoMatchWebViewPolicyDecisionHandler()
        let matchSpy1 = MatchWebViewPolicyDecisionHandler()
        let matchSpy2 = MatchWebViewPolicyDecisionHandler()

        policyManager = WebViewPolicyManager(
            policyDecisionHandlers: [
                noMatchSpy,
                matchSpy1,
                matchSpy2
            ]
        )

        let result = policyManager.decidePolicy(
            for: Self.navigationAction,
            configuration: navigatorConfiguration,
            navigator: navigator
        )

        XCTAssertTrue(noMatchSpy.matchesWasCalled)
        XCTAssertFalse(noMatchSpy.handleWasCalled)
        XCTAssertTrue(matchSpy1.matchesWasCalled)
        XCTAssertTrue(matchSpy1.handleWasCalled)
        XCTAssertFalse(matchSpy2.matchesWasCalled)
        XCTAssertFalse(matchSpy2.handleWasCalled)
        XCTAssertEqual(result, WebViewPolicyManager.Decision.cancel)
    }
}

final class NoMatchWebViewPolicyDecisionHandler: WebViewPolicyDecisionHandler {
    let name: String = "no-match-spy"
    var matchesWasCalled = false
    var handleWasCalled = false

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool {
        matchesWasCalled = true
        return false
    }

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> WebViewPolicyManager.Decision {
        handleWasCalled = true
        return .cancel
    }
}

final class MatchWebViewPolicyDecisionHandler: WebViewPolicyDecisionHandler {
    let name: String = "match-spy"
    var matchesWasCalled = false
    var handleWasCalled = false

    func matches(navigationAction: WKNavigationAction,
                 configuration: Navigator.Configuration) -> Bool {
        matchesWasCalled = true
        return true
    }

    func handle(navigationAction: WKNavigationAction,
                configuration: Navigator.Configuration,
                navigator: Navigator) -> WebViewPolicyManager.Decision {
        handleWasCalled = true
        return .cancel
    }
}
