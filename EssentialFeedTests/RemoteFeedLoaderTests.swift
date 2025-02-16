//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Brian Blanco on 2/12/25.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let(_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLS.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()

        XCTAssertEqual(client.requestedURLS, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()
        sut.load()

        XCTAssertEqual(client.requestedURLS, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0)

        var capturedErrors = [RemoteFeedLoader.Error]()

        sut.load { capturedErrors.append($0) }

        XCTAssertEqual(capturedErrors, [.connectivity])
    }

    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)

        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURLS = [URL]()
        var error: Error?

        func get(from url: URL, completion: @escaping (Error) -> Void) {
            if let error = error {
                completion(error)
            }

            requestedURLS.append(url)
        }
    }
}

