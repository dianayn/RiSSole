import Foundation

struct DescriptionViewModel {
    let title = Observable<String, Error>()
    let description = Observable<String, Error>()

    init(title: String?, description: String?) {
        self.title.next(title ?? "Article")
        self.description.next(description ?? "no description available")
    }

    var html: Observable<String, Error> {
        let html = Observable<String, Error>()

        html.next("<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\"</head><body>\(description)</body></html>")

        return html
    }

    // 1. make Observable
    // 2. .next("blah")
    // 3. there are no observers, so nothiung happens, but the Observable saves "blah"
    // 4. add Observer1
    // 5. Observer1 gets called with "blah"
    // 6. .next("bling")
    // 7. Observer1 gets called with "bling"
    // 8. add Observer2
    // 9. Observer2 gets called with "bling"
    // 10. .next("blunk")
    // 11. Observer1 and Observer2 get called with blunk:"

}
