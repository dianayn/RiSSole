//
//  DescriptionViewController.swift
//  RiSSole
//
//  Created by Matt Beshara on 21/5/20.
//  Copyright © 2020 Matt Beshara. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class DescriptionViewController: UIViewController {

    var item: [String: String]

    var webView = WKWebView()

    init(item: [String: String]) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = item["title"]

        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(webView)

        view.addConstraints([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)])


        let html = "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\"</head><body>" + item["description"]! + "</body></html>"
        webView.loadHTMLString(html, baseURL: nil)
    }


}
