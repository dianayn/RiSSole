import Foundation
import UIKit
import WebKit

class DescriptionViewController: UIViewController {
    let bag = DisposeBag()

    var webView = WKWebView()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(webView)

        view.addConstraints([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)])

    }

    func update(_ viewModel: DescriptionViewModel) {
        viewModel.title.observe { [weak self] in
            self?.title = $0
        }.dispose(in: bag)

        viewModel.html.observe { [weak self] in
            self?.webView.loadHTMLString($0, baseURL: nil)
        }.dispose(in: bag)
    }
}
