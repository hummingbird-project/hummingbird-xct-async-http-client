//===----------------------------------------------------------------------===//
//
// This source file is part of the Hummingbird server framework project
//
// Copyright (c) 2021-2021 the Hummingbird authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See hummingbird/CONTRIBUTORS.txt for the list of Hummingbird authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import AsyncHTTPClient
import Hummingbird
import HummingbirdXCT
import NIOCore
import NIOPosix
import NIOTransportServices
import XCTest

/// Test using a live server and AsyncHTTPClient
class HBXCTAsyncHTTPClient: HBXCT {
    init(configuration: HTTPClient.Configuration) {
        self.client = HTTPClient(configuration: configuration)
    }

    /// Start tests
    func start(application: HBApplication) throws {
        do {
            try application.start()
            self.baseURL = "http://localhost:\(application.server.port!)"
        } catch {
            try self.client.syncShutdown()
            throw error
        }
    }

    /// Stop tests
    func stop(application: HBApplication) {
        XCTAssertNoThrow(_ = try self.client.syncShutdown())
        application.stop()
        application.wait()
    }

    /// Send request and call test callback on the response returned
    func execute(
        uri: String,
        method: HTTPMethod,
        headers: HTTPHeaders = [:],
        body: ByteBuffer? = nil
    ) -> EventLoopFuture<HBXCTResponse> {
        guard let baseURL = self.baseURL else {
            return self.eventLoopGroup.next().makeFailedFuture(HBXCTError.notStarted)
        }
        let fullURI: String
        if uri.first == "/" {
            fullURI = "\(baseURL)\(uri)"
        } else {
            fullURI = "\(baseURL)/\(uri)"
        }
        do {
            let request = try HTTPClient.Request(url: fullURI, method: method, headers: headers, body: body.map {.byteBuffer($0)})
            return client.execute(request: request)
                .map { response in
                    return .init(status: response.status, headers: response.headers, body: response.body)
                }
        } catch {
            return self.eventLoopGroup.next().makeFailedFuture(error)
        }
    }

    var eventLoopGroup: EventLoopGroup { self.client.eventLoopGroup }
    var baseURL: String?
    let client: HTTPClient
}
