//
//  FeedListViewController.swift
//  RiSSole
//
//  Created by Matt Beshara on 21/5/20.
//  Copyright © 2020 Matt Beshara. All rights reserved.
//

import Foundation
import UIKit

class FeedListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let df = DataFetcher(urlSession: URLSession.shared)

    let feedArray: Array = ["zhttps://www.abc.net.au/news/feed/51120/rss.xml", "https://feeds.macrumors.com/MacRumors-All"]

    let feedTableView = UITableView()
    let spinner = UIActivityIndicatorView(style: .large)
    lazy var refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))

    override func viewDidLoad() {
        super.viewDidLoad()

        df.handleClientError = { error in print(error) }
        df.handleServerError = { response in print(response) }

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
        df.fetch(url) { [weak self] data in
            sleep(5)
            DispatchQueue.main.async {
                let feedVC = FeedViewController(data: data)
                self?.show(feedVC, sender: self)
            }
        }

    }

    @objc
    func refresh() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
    }


}
