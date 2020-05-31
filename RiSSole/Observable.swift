import Foundation

class Observer<T> {
    let closure: (T) -> Void
    init(_ closure: @escaping (T) -> Void) {
        self.closure = closure
    }
}

class Observable<Value> {
    private let observers = NSHashTable<Observer<Value>>.weakObjects()
    private var mostRecentValue: Value?

    init() {}

    init(_ initialValue: Value) {
        mostRecentValue = initialValue
    }

    func next(_ value: Value) {
        mostRecentValue = value
        observers.allObjects.forEach { $0.closure(value) }
    }

    func observe(_ closure: @escaping (Value) -> Void) -> Disposable {
        mostRecentValue.map(closure)
        let observer = Observer(closure)
        observers.add(observer)
        return Disposable(self, observer)
    }
}

class Disposable: NSObject {
    let references: Any
    init(_ references: Any...) {
        self.references = references
    }

    func dispose(in bag: DisposeBag) {
        bag.add(self)
    }
}

typealias DisposeBag = NSMutableSet
