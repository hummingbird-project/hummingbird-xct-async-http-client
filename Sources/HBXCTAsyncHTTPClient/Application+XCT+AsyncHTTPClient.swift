import AsyncHTTPClient
import Hummingbird
import HummingbirdXCT

/// Type of test framework
public enum XCTAHCTestingSetup {
    public enum Scheme: CustomStringConvertible {
        case http
        case https

        public var description: String {
            switch self {
            case .http: return "http"
            case .https: return "https"
            }
        }
    }
    case ahc(scheme: Scheme)
}

/// Extends `HBApplication` to support testing of applications with AsyncHTTPClient
///
/// You use `XCTStart`, `XCTStop` and `XCTExecute` to run test applications.
/// ```
/// let app = HBApplication(testing: .ahc)
/// app.router.get("/hello") { _ in
///     return "hello"
/// }
/// app.XCTStart()
/// defer { app.XCTStop() }
///
/// // does my app return "hello" in the body for this route
/// app.XCTExecute(uri: "/hello", method: .GET) { response in
///     let body = try XCTUnwrap(response.body)
///     XCTAssertEqual(String(buffer: body, "hello")
/// }
/// ```
extension HBApplication {
    // MARK: Initialization

    /// Creates a version of `HBApplication` that can be used for testing code
    ///
    /// - Parameters:
    ///   - testing: indicates we want to test with AsyncHTTPClient
    ///   - configuration: configuration of application
    ///   - clientConfiguration: HTTPClient configuration setup
    public convenience init(
        testing: XCTAHCTestingSetup, 
        configuration: HBApplication.Configuration = .init(), 
        clientConfiguration: HTTPClient.Configuration = .init()
    ) {
        let xct: HBXCT
        let configuration = configuration.with(address: .hostname("localhost", port: 0))
        switch testing {
        case .ahc(let scheme):
            xct = HBXCTAsyncHTTPClient(scheme: scheme, configuration: clientConfiguration)
        }
        self.init(configuration: configuration, eventLoopGroupProvider: .shared(xct.eventLoopGroup))
        self.extensions.set(\.xct, value: xct)
    }
}

