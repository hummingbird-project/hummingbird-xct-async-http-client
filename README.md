# HummingbirdXCT AsyncHTTPClient

Test client for Hummingbird server framework that uses the swift server [AsyncHTTPClient](https://github.com/swift-server/async-http-client) as its test client instead of the internal test client Hummingbird provides.

Use this if you want to test things like TLS and HTTP2.

```swift
let app = HBApplication(testing: .ahc(scheme: .https))
app.router.get("/hello") { request -> EventLoopFuture<ByteBuffer> in
    let buffer = request.allocator.buffer(string: "Hello")
    return request.eventLoop.makeSucceededFuture(buffer)
}
try app.XCTStart()
defer { app.XCTStop() }

try app.XCTExecute(uri: "/hello", method: .GET) { response in
    var body = try XCTUnwrap(response.body)
    let string = body.readString(length: body.readableBytes)
    XCTAssertEqual(response.status, .ok)
    XCTAssertEqual(string, "Hello")
}
```
