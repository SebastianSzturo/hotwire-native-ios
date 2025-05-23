@testable import HotwireNative
import XCTest

final class SafariViewControllerRouteDecisionHandlerTests: XCTestCase {
    let navigatorConfiguration = Navigator.Configuration(
        name: "test",
        startLocation: URL(string: "https://my.app.com")!
    )
    var navigator: Navigator!
    var route: SafariViewControllerRouteDecisionHandler!

    override func setUp() {
        route = SafariViewControllerRouteDecisionHandler()
        navigator = Navigator(configuration: navigatorConfiguration)
    }

    func test_handling_matching_result_stops_navigation() {
        let url = URL(string: "https://external.com/page")!
        let result = route.handle(location: url, configuration: navigatorConfiguration, navigator: navigator)
        XCTAssertEqual(result, Router.Decision.cancel)
    }

    func test_url_on_external_domain_matches() {
        let url = URL(string: "https://external.com/page")!
        let result = route.matches(location: url, configuration: navigatorConfiguration)

        XCTAssertTrue(result)
    }

    func test_url_without_subdomain_matches() {
        let url = URL(string: "https://app.com/page")!
        let result = route.matches(location: url, configuration: navigatorConfiguration)

        XCTAssertTrue(result)
    }

    func test_url_on_app_domain_does_not_match() {
        let url = URL(string: "https://my.app.com/page")!
        let result = route.matches(location: url, configuration: navigatorConfiguration)

        XCTAssertFalse(result)
    }

    func test_non_http_urls_do_not_match() {
        let url = URL(string: "file:///path/to/file")!
        let result = route.matches(location: url, configuration: navigatorConfiguration)
        
        XCTAssertFalse(result)
    }
}
