import UIKit

class ItemListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let router: Routable

    let tableView = UITableView()
    var items: [ItemViewModel] = []
    var descriptionViewModels: [DescriptionViewModel] = []

    let df = DataFetcher(urlSession: URLSession.shared)
    var bag = DisposeBag()

    init(router: Routable) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        view.addConstraints([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")


        tableView.dataSource = self
        tableView.delegate = self
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)

        cell.accessoryType = .detailButton

        let item = items[indexPath.row]

        item.title
            .observe { cell.textLabel?.text = $0 }
            .dispose(in: bag)

        item.image
            .observe { image in
                DispatchQueue.main.async {
                    cell.imageView?.image = image
                    cell.setNeedsLayout()
                }
            }
            .dispose(in: bag)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        descriptionViewModels[indexPath.row].open()
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        items[indexPath.row].open()
    }

    func update(_ viewModel: ItemListViewModel) {
        bag = DisposeBag()

        viewModel.feed
            .observe { [weak self] in
                $0.title.map { self?.title = $0 }
            }
            .dispose(in: bag)

        viewModel.itemViewModels
            .observe { [weak self] in
                self?.items = $0
            }
            .dispose(in: bag)

        viewModel.descriptionViewModels
            .observe { [weak self] in
                self?.descriptionViewModels = $0
            }
            .dispose(in: bag)

        viewModel.errorStream.observe { print("error: \($0)") }.dispose(in: bag)
    }
}

