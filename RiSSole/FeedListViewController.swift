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

    let feedArray: Array = ["https://www.abc.net.au/news/feed/51120/rss.xml", "https://feeds.macrumors.com/MacRumors-All"]

    let feedTableView = UITableView()

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

        let url = URL(string: feedArray[indexPath.row])
        let feedVC = FeedViewController(feedURL: url!)
//        navigationController!.pushViewController(feedVC, animated: true)
        show(feedVC, sender: self)
    }


}
