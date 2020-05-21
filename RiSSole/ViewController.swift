//
//  InitialViewController.swift
//  RiSSole
//
//  Created by Matt Beshara on 21/5/20.
//  Copyright © 2020 Matt Beshara. All rights reserved.
//

import UIKit
import SafariServices

class InitialViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView()
    var feedInfo: [String: String]!
    var items: [[String: String]]!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Article"

        (feedInfo, items) = RSSParser.parse(contentsOf: URL(string: "http://feeds.macrumors.com/MacRumors-All")!)


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
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: items[indexPath.row]["link"]!)!
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .formSheet
//        show(safariViewController, sender: self)
        present(safariViewController, animated: true)
    }


}

