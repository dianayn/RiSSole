import Foundation

class DescriptionViewModel {
    let title = Observable<String>()
    let description = Observable<String>()
    let html = Observable<String>()

    let router: Routable
    let bag = DisposeBag()

    init(router: Routable, feedItem: Feed.Item) {
        self.router = router
        self.title.next(feedItem.title ?? "Article")
        self.description.next(feedItem.description ?? "No description available.")
        self.description.observe { [weak self] in
            self?.html.next("<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\"</head><body>\($0)</body></html>")
        }
        .dispose(in: bag)
    }

    func open() {
        router.route(to: .description(viewModel: self))
    }
}
