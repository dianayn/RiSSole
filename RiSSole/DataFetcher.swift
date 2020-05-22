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

    func fetch(_ url: URL) -> Observable<Data, Error?> {
        let observable = Observable<Data, Error?>()
        fetch(url,
              success: {
                [weak observable] in observable?.next($0)
            },
              failure: {
                [weak observable] in observable?.error($0)
        })
        return observable
    }
}
