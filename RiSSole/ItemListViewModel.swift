import UIKit

struct RSSParserError: Error {}

extension String {
    func findImageURL() -> URL? {
        guard let imageURLRegex = try? NSRegularExpression(pattern: "(<img.+?src=\"(.+?)\".*?>)", options: []) else {
            return nil
        }

        let nsSelf = NSString(string: self)
        let matches = imageURLRegex.matches(in: nsSelf as String, options: [], range: NSRange(location: 0, length: nsSelf.length))
        guard let match = matches.first, match.numberOfRanges > 1 else {
            return nil
        }

        let range = match.range(at: 2)
        return URL(string: nsSelf.substring(with: range))
    }
}

class ItemViewModel {
    let link = Observable<URL>()
    let title = Observable<String>()
    let image = Observable<UIImage>()
    var open: () -> Void = {}

    let router: Routable
    let dataFetcher = DataFetcher(urlSession: URLSession.shared)
    let bag = DisposeBag()

    init(router: Routable, feedItem: Feed.Item) {
        self.router = router
        feedItem.link.map { URL(string: $0).map(link.next) }
        feedItem.title.map(title.next)
        if let imageURL = feedItem.description?.findImageURL() {
            let (dataObservable, errorObservable) = dataFetcher.fetch(imageURL)
            dataObservable.observe { [weak self] in
                if let self = self, let image = UIImage(data: $0) {
                    self.image.next(image)
                }
            }.dispose(in: bag)
            errorObservable.observe { print("error: \(String(describing: $0))") }.dispose(in: bag)
        }

        link.observe { [weak self] link in
            self?.open = { router.route(to: .safari(viewModel: SafariViewModel(url: link))) }
        }
        .dispose(in: bag)
    }
}

class ItemListViewModel {
    let feed = Observable<Feed>()
    let items = Observable<[Feed.Item]>()
    let itemViewModels = Observable<[ItemViewModel]>()
    let descriptionViewModels = Observable<[DescriptionViewModel]>()
    let errorStream = Observable<RSSParserError>()

    let router: Routable
    let bag = DisposeBag()

    init(router: Routable, data: Data) {
        self.router = router
        if let feedModel = RSSParser.parse(data: data) {
            feed.next(feedModel)
        } else {
            errorStream.next(RSSParserError())
        }

        feed.observe { [weak self] in
            self?.items.next($0.items)
        }.dispose(in: bag)

        items.observe { [weak self] in
            self?.itemViewModels.next($0.map {
                ItemViewModel(router: router, feedItem: $0)
            })
        }.dispose(in: bag)

        items.observe { [weak self] in
            self?.descriptionViewModels.next($0.map {
                DescriptionViewModel(router: router, feedItem: $0)
            })
        }.dispose(in: bag)
    }
}
