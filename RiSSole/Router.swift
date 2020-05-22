import Foundation
import SafariServices

enum Screen {
    case feedList(feedURLs: [URL])
    case itemList(viewModel: ItemListViewModel)
    case description(viewModel: DescriptionViewModel)
    case safari(viewModel: SafariViewModel)
}

protocol Routable {
    func route(to screen: Screen)
}

struct Router: Routable {
    let rootNavigationController: UINavigationController

    func route(to screen: Screen) {
        switch screen {
        case let .feedList(feedURLs):
            break
        case let .itemList(viewModel):
            let itemListViewController = ItemListViewController(router: self)
            itemListViewController.update(viewModel)
            rootNavigationController.show(itemListViewController, sender: self)
        case let .description(viewModel):
            let descriptionViewController = DescriptionViewController()
            descriptionViewController.update(viewModel)
            rootNavigationController.show(descriptionViewController, sender: self)
        case let .safari(viewModel):
            let safariViewController = SFSafariViewController(url: viewModel.url)
            safariViewController.modalPresentationStyle = .formSheet
            rootNavigationController.present(safariViewController, animated: true)
        }
    }
}

struct SafariViewModel {
    let url: URL
}
