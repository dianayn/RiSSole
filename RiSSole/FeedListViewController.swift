import Foundation
import UIKit

class FeedListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var router: Routable!

//    init(router: Router) {
//        self.router = router
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    let df = DataFetcher(urlSession: URLSession.shared)
    let bag = DisposeBag()

    let feedArray: Array = ["https://www.abc.net.au/news/feed/51120/rss.xml", "https://feeds.macrumors.com/MacRumors-All"]

    let feedTableView = UITableView()
    let spinner = UIActivityIndicatorView(style: .large)
    lazy var refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))

    override func viewDidLoad() {
        super.viewDidLoad()

                title = "Feeds"

        feedTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(feedTableView)

        view.addConstraints([
            feedTableView.topAnchor.constraint(equalTo: view.topAnchor),
            feedTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            feedTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            feedTableView.rightAnchor.constraint(equalTo: view.rightAnchor)])

        feedTableView.register(UITableViewCell.self, forCellReuseIdentifier: "feedList")

        feedTableView.dataSource = self
        feedTableView.delegate = self

        spinner.startAnimating()
        navigationItem.rightBarButtonItem = refreshButton
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedList", for: indexPath)
        cell.textLabel?.text = "\(feedArray[indexPath.row])"
        cell.accessoryType = .disclosureIndicator



        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let url = URL(string: feedArray[indexPath.row])!

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)

        let dataObservable = df.fetch(url)
        dataObservable
            .onError {
                print("got network error")
                print("Error: \($0)")
            }
            .observe { [weak self] data in
                print("got network data")
                DispatchQueue.main.async {
                    self?.router.map {
                        self?.router.route(to: .itemList(viewModel: ItemListViewModel(router: $0, data: data)))
                    }
                }
            }
            .dispose(in: bag)
//        print("After here, the network request should be cancelled")
    }

    @objc
    func refresh() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
    }


}
