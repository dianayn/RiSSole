import UIKit

public struct Feed {
    fileprivate(set) var link: String?
    fileprivate(set) var title: String?
    fileprivate(set) var items: [Item] = []

    public struct Item {
        fileprivate(set) var link: String?
        fileprivate(set) var title: String?
        fileprivate(set) var pubDate: String?
        fileprivate(set) var description: String?
    }
}

protocol ElementProtocol {}
enum Element: String, ElementProtocol {
    case rss
    enum RSS: String, ElementProtocol {
        case channel
        enum Channel: String, ElementProtocol {
            case link
            case title
            case item
            enum Item: String, ElementProtocol {
                case link
                case title
                case pubDate
                case description
            }
        }
    }
}
struct IgnoredElement: ElementProtocol {
    let name: String
    let container: ElementProtocol?
}

class RSSParser: NSObject, XMLParserDelegate {
    static func parse(data: Data) -> Feed? {
        let parser = XMLParser(data: data)
        let delegate = RSSParser()
        parser.delegate = delegate
        parser.parse()
        return delegate.feed
    }

    var feed: Feed?
    var currentItem = Feed.Item()

    private var containerElement: ElementProtocol?

    func parserDidStartDocument(_ parser: XMLParser) {
        feed = Feed()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        partialString = ""
        switch containerElement {
        case .none:
            guard let rssElement = Element(rawValue: elementName) else {
                containerElement = IgnoredElement(name: elementName, container: containerElement)
                return
            }
            containerElement = rssElement
        case .some(Element.rss):
            guard let channelElement = Element.RSS(rawValue: elementName) else {
                containerElement = IgnoredElement(name: elementName, container: containerElement)
                return
            }
            containerElement = channelElement
        case .some(Element.RSS.channel):
            guard let newElement = Element.RSS.Channel(rawValue: elementName) else {
                containerElement = IgnoredElement(name: elementName, container: containerElement)
                return
            }
            containerElement = newElement
        case .some(Element.RSS.Channel.item):
            guard let newElement = Element.RSS.Channel.Item(rawValue: elementName) else {
                containerElement = IgnoredElement(name: elementName, container: containerElement)
                return
            }
            containerElement = newElement
        default: break
        }
    }

    private var partialString: String = ""
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        partialString = partialString + string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let ignoredElement = containerElement as? IgnoredElement,
            ignoredElement.name == elementName {
            containerElement = ignoredElement.container
        } else if let element = containerElement as? Element.RSS.Channel.Item {
            switch element {
            case .description: currentItem.description = partialString
            case .link: currentItem.link = partialString
            case .pubDate: currentItem.pubDate = partialString
            case .title: currentItem.title = partialString
            }
            containerElement = Element.RSS.Channel.item
        } else if let element = containerElement as? Element.RSS.Channel {
            switch element {
            case .link: feed?.link = partialString
            case .title: feed?.title = partialString
            case .item:
                feed?.items.append(currentItem)
                currentItem = Feed.Item()
            }
            containerElement = Element.RSS.channel
        } else if containerElement is Element.RSS {
            containerElement = Element.rss
        } else if containerElement is Element {
            containerElement = nil
        }
    }
}
