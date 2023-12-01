import Hummingbird
import HBXCTAsyncHTTPClient
import XCTest

final class HBXCTAsyncHTTPClientTests: XCTestCase {
    func testGet() throws {
        let app = HBApplication(testing: .ahc(scheme: .http))
        app.router.get("/hello") { request -> EventLoopFuture<ByteBuffer> in
            let buffer = request.allocator.buffer(string: "GET: Hello")
            return request.eventLoop.makeSucceededFuture(buffer)
        }
        try app.XCTStart()
        defer { app.XCTStop() }

        try app.XCTExecute(uri: "/hello", method: .GET) { response in
            var body = try XCTUnwrap(response.body)
            let string = body.readString(length: body.readableBytes)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(string, "GET: Hello")
        }
    }

    func testLeadingSlash() throws {
        let app = HBApplication(testing: .ahc(scheme: .http))
        app.router.get("/hello") { request -> EventLoopFuture<ByteBuffer> in
            let buffer = request.allocator.buffer(string: "GET: Hello")
            return request.eventLoop.makeSucceededFuture(buffer)
        }
        try app.XCTStart()
        defer { app.XCTStop() }

        try app.XCTExecute(uri: "/hello", method: .GET) { response in
            var body = try XCTUnwrap(response.body)
            let string = body.readString(length: body.readableBytes)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(string, "GET: Hello")
        }
        try app.XCTExecute(uri: "hello", method: .GET) { response in
            var body = try XCTUnwrap(response.body)
            let string = body.readString(length: body.readableBytes)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(string, "GET: Hello")
        }
    }

    func testStatus() throws {
        let app = HBApplication(testing: .ahc(scheme: .http))
        app.router.put("/test") { request -> HTTPResponseStatus in
            return .imATeapot
        }
        try app.XCTStart()
        defer { app.XCTStop() }

        try app.XCTExecute(uri: "/test", method: .PUT) { response in
            XCTAssertEqual(response.status, .imATeapot)
        }
    }

    func testHeaders() throws {
        let app = HBApplication(testing: .ahc(scheme: .http))
        app.router.post("/test") { request -> HBResponse in
            return .init(status: .ok, headers: ["output": request.headers["input"].first ?? ""])
        }
        try app.XCTStart()
        defer { app.XCTStop() }

        try app.XCTExecute(uri: "/test", method: .POST, headers: ["input": "hello"]) { response in
            XCTAssertEqual(response.headers["output"].first, "hello")
        }
    }

    func testBody() throws {
        let app = HBApplication(testing: .ahc(scheme: .http))
        app.router.put("/test/:string") { request -> String? in
            return request.parameters["string"]
        }
        try app.XCTStart()
        defer { app.XCTStop() }

        try app.XCTExecute(uri: "/test/this", method: .PUT) { response in
            let body = try XCTUnwrap(response.body)
            XCTAssertEqual(body, ByteBuffer(string: "this"))
        }
    }
}
