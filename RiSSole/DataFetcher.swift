import Foundation

protocol URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

protocol DataFetcherProtocol {
    func fetch(_ url: URL, success: @escaping (Data) -> Void, failure: @escaping (Error?) ->  Void)
}

struct URLResponseError: Error {
    let response: URLResponse
}

class DataFetcher: DataFetcherProtocol {
    let urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol) {
        self.urlSession = urlSession
    }

    func fetch(_ url: URL,
               success: @escaping (Data) -> Void,
               failure: @escaping (Error?) ->  Void) {
        let task = urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                failure(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    failure(response.map(URLResponseError.init))
                return
            }
            if let data = data {
                success(data)
            }
        }
        task.resume()
    }

    func fetch(_ url: URL) -> (Observable<Data>, Observable<Error?>) {
        let dataObservable = Observable<Data>()
        let errorObservable = Observable<Error?>()
        fetch(url,
              success: {
                [weak dataObservable] in dataObservable?.next($0)
            },
              failure: {
                [weak errorObservable] in errorObservable?.next($0)
        })
        return (dataObservable, errorObservable)
    }
}
