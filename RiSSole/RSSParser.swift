import UIKit

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
    static func parse(data: Data) -> (feedInfo: [String: String], items: [[String: String]]) {
        let parser = XMLParser(data: data)
        let delegate = RSSParser()
        parser.delegate = delegate
        parser.parse()
        return (delegate.feedInfo, delegate.items)
    }

    var feedInfo: [String: String] = [:]
    var items: [[String: String]] = []
    var currentItem: [String: String] = [:]

    private var containerElement: ElementProtocol?

    func parserDidStartDocument(_ parser: XMLParser) {
        feedInfo = [:]
        items = []
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
            case .description: currentItem[Element.RSS.Channel.Item.description.rawValue] = partialString
            case .link: currentItem[Element.RSS.Channel.Item.link.rawValue] = partialString
            case .pubDate: currentItem[Element.RSS.Channel.Item.pubDate.rawValue] = partialString
            case .title: currentItem[Element.RSS.Channel.Item.title.rawValue] = partialString
            }
            containerElement = Element.RSS.Channel.item
        } else if let element = containerElement as? Element.RSS.Channel {
            switch element {
            case .link: feedInfo[Element.RSS.Channel.link.rawValue] = partialString
            case .title: feedInfo[Element.RSS.Channel.title.rawValue] = partialString
            case .item:
                items.append(currentItem)
                currentItem = [:]
            }
            containerElement = Element.RSS.channel
        } else if containerElement is Element.RSS {
            containerElement = Element.rss
        } else if containerElement is Element {
            containerElement = nil
        }
    }
}
