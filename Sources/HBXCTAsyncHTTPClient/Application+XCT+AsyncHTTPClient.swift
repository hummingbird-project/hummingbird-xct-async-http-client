import AsyncHTTPClient
import Hummingbird
import HummingbirdXCT

/// Type of test framework
public enum XCTAHCTestingSetup {
    case ahc
}

/// Extends `HBApplication` to support testing of applications
///
/// You use `XCTStart`, `XCTStop` and `XCTExecute` to run test applications. You can either create an
/// "embedded" application which uses the `EmbeddedChannel` for testing your code or a "live" application.
/// An "embedded" application test is quicker and doesn't require setting up a full server but if you code is reliant
/// on multi-threading it will fail. In that situation you should use a "live" application which will setup a local server.
///
/// The example below is using the `.embedded` framework to test
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
    ///   - testing: indicates which type of testing framework we want
    ///   - configuration: configuration of application
    public convenience init(
        testing: XCTAHCTestingSetup, 
        configuration: HBApplication.Configuration = .init(), 
        clientConfiguration: HTTPClient.Configuration = .init()
    ) {
        let xct: HBXCT
        let configuration = configuration.with(address: .hostname("localhost", port: 0))
        switch testing {
        case .ahc:
            xct = HBXCTAsyncHTTPClient(configuration: clientConfiguration)
        }
        self.init(configuration: configuration, eventLoopGroupProvider: .shared(xct.eventLoopGroup))
        self.extensions.set(\.xct, value: xct)
    }
}

