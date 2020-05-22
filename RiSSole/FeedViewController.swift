import UIKit
import SafariServices

class ItemListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let data: Data

    let tableView = UITableView()
    var feedInfo: [String: String]!
    var items: [[String: String]]!

    let df = DataFetcher(urlSession: URLSession.shared)
    let bag = DisposeBag()

    init(data: Data) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Article"

        (feedInfo, items) = RSSParser.parse(data: data)


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
        cell.textLabel?.text = "\(items[indexPath.row]["title"]!)"
        cell.accessoryType = .detailButton


        let description = NSString(string: items[indexPath.row]["description"]!)
        let regex = try? NSRegularExpression(pattern: "(<img.+?src=\"(.+?)\".*?>)", options: [])
        let matches = regex?.matches(in: description as String, options: [], range: NSRange(location: 0, length: description.length))
        if let match = matches?.first, match.numberOfRanges > 1 {
            let range = match.range(at: 2)
            let imgURL = URL(string: NSString(string: description).substring(with: range))!
//print(imgURL)

            df.fetch(imgURL)
                .observe {
                    let image = UIImage(data: $0)
                    DispatchQueue.main.async {
                        cell.imageView?.image = image
                        cell.setNeedsLayout()
                    }
                }
               .dispose(in: bag)


        }



        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        let descriptionViewModel = DescriptionViewModel(title: item["title"], description: item["description"])
        let descriptionViewController = DescriptionViewController()
        descriptionViewController.update(descriptionViewModel)
        show(descriptionViewController, sender: self)
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
         let url = URL(string: items[indexPath.row]["link"]!)!
                let safariViewController = SFSafariViewController(url: url)
                safariViewController.modalPresentationStyle = .formSheet
        //        show(safariViewController, sender: self)
                present(safariViewController, animated: true)
    }


}

