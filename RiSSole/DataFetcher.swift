import Foundation

protocol URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

protocol DataFetcherProtocol {
    var handleClientError: (Error) ->  Void { get set }
    var handleServerError: (URLResponse?)-> Void { get set }
    func fetch(_ url: URL, success: @escaping (Data) -> Void)
}

class DataFetcher: DataFetcherProtocol {
    let urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol) {
        self.urlSession = urlSession
    }

    var handleClientError: (Error) -> Void = { _ in }
    var handleServerError: (URLResponse?)-> Void = { _ in }

    func fetch(_ url: URL, success: @escaping (Data) -> Void) {
        let task = urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                self.handleClientError(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                self.handleServerError(response)
                return
            }
            if let data = data {
                success(data)
            }
        }
        task.resume()
    }
}
