import Foundation

class Observer<T> {
    let closure: (T) -> Void
    init(_ closure: @escaping (T) -> Void) {
        self.closure = closure
    }

    deinit {
        print("\(self)")
    }
}

class Observable<Value, Error> {
    var mostRecentValue: Value
    init(_ initialValue: Value) {
        mostRecentValue = initialValue
    }

    let observers = NSHashTable<Observer<Value>>.weakObjects()
    let onErrors = NSHashTable<Observer<Error>>.weakObjects()

    func next(_ value: Value) {
        mostRecentValue = value
        observers.allObjects.forEach { $0.closure(value) }
    }

    func error(_ error: Error) {
        onErrors.allObjects.forEach { $0.closure(error) }
    }

    func observe(_ closure: @escaping (Value) -> Void) -> DisposableClosure<Value, Error> {
        closure(mostRecentValue)
        let observer = Observer(closure)
        observers.add(observer)
        return DisposableClosure(self, observer)
    }

    func onError(_ closure: @escaping (Error) -> Void) -> DisposableClosure<Value, Error> {
        let onError = Observer(closure)
        onErrors.add(onError)
        return DisposableClosure(self, onError)
    }

    deinit {
        print("\(self)")
    }
}

protocol Disposable {}

class DisposableClosure<Value, Error>: Disposable {
    let observable: Observable<Value, Error>
    let closure: Any
    init(_ observable: Observable<Value, Error>, _ closure: Any) {
        self.observable = observable
        self.closure = closure
    }

    var previousDisposable: DisposableClosure<Value, Error>?

    func dispose(in bag: DisposeBag) {
        bag.add(self)
    }

    func observe(_ closure: @escaping (Value) -> Void) -> DisposableClosure<Value, Error> {
        let newDisposable = observable.observe(closure)
        newDisposable.previousDisposable = self
        return newDisposable
    }

    func onError(_ closure: @escaping (Error) -> Void) -> DisposableClosure<Value, Error> {
        let newDisposable = observable.onError(closure)
        newDisposable.previousDisposable = self
        return newDisposable
    }

    deinit {
        print("\(self)")
    }
}

class DisposeBag {
    var disposables: [Disposable] = []
    func add(_ disposable: Disposable) {
        disposables.append(disposable)
    }

    deinit {
        print("\(self)")
    }
}


let bag = DisposeBag()

let observable = Observable<String, Never>("blah")
observable.next("bling")
print("no observers yet...")
observable.observe { print("i'm number 1: \($0)") } /// .dispose(in: bag)
observable.next("bloo")
observable.observe { print("second is best: \($0)") }
observable.next("blorp")

