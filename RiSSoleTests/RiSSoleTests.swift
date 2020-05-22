import XCTest
@testable import RiSSole

class MockURLSessionDataTask: URLSessionDataTask {
    var completionHandler: () -> Void
    init(completionHandler: @escaping () -> Void) {
        self.completionHandler = completionHandler
    }
    override func resume() {
        self.completionHandler()
    }
}

class MockURLSession: URLSessionProtocol {
    let data: Data?
    let urlResponse: URLResponse?
    let error: Error?

    init(data: Data?, urlResponse: URLResponse?, error: Error?) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
    }

    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        MockURLSessionDataTask(completionHandler: { [weak self] in
            completionHandler(self?.data, self?.urlResponse, self?.error)
        })
    }
}

struct MockError: Error, Equatable {}

class DataFetcherTests: XCTestCase {
    var mockURLSession: MockURLSession!
    var dataFetcher: DataFetcher!

    func testSuccess() throws {
        let url = URL(string: "http://example.com")!
        let expectedData = Data()
        mockURLSession = MockURLSession(data: expectedData, urlResponse: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil), error: nil)
        dataFetcher = DataFetcher(urlSession: mockURLSession)
        let expectation = XCTestExpectation()
        dataFetcher.fetch(url) { data in
            XCTAssert(data == expectedData)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testClientError() throws {
        let url = URL(string: "http://example.com")!
        let expectedError = MockError()
        mockURLSession = MockURLSession(data: nil, urlResponse: nil, error: expectedError)
        dataFetcher = DataFetcher(urlSession: mockURLSession)
        let expectation = XCTestExpectation()
        dataFetcher.handleClientError = { error in
            XCTAssert(error as! MockError == expectedError)
            expectation.fulfill()
        }
        dataFetcher.fetch(url) { _ in }
        wait(for: [expectation], timeout: 1)
    }

    func testServerError() throws {
        let url = URL(string: "http://example.com")!
        let expectedResponse = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        mockURLSession = MockURLSession(data: nil, urlResponse: expectedResponse, error: nil)
        dataFetcher = DataFetcher(urlSession: mockURLSession)
        let expectation = XCTestExpectation()
        dataFetcher.handleServerError = { response in
            XCTAssert(response == expectedResponse)
            expectation.fulfill()
        }
        dataFetcher.fetch(url) { _ in }
        wait(for: [expectation], timeout: 1)
    }
}
