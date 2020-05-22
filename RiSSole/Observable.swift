import Foundation

class Observer<T> {
    let closure: (T) -> Void
    init(_ closure: @escaping (T) -> Void) {
        self.closure = closure
    }
}

class Obseravble<T, U> {
    let observers = NSHashTable<Observer<T>>()
    let onErrors = NSHashTable<Observer<U>>()

    func next(_ value: T) {
        observers.allObjects.forEach { $0.closure(value) }
    }

    func error(_ error: U) {
        onErrors.allObjects.forEach { $0.closure(error) }
    }

    func observe(_ closure: @escaping (T) -> Void) -> Disposable<T, U> {
        let observer = Observer(closure)
        observers.add(observer)
        return Disposable(self, observer)
    }

    func onError(_ closure: @escaping (U) -> Void) -> Disposable<T, U> {
        let onError = Observer(closure)
        onErrors.add(onError)
        return Disposable(self, onError)
    }
}

class Disposable<T, U> {
    let observable: Obseravble<T, U>
    let closure: Any
    init(_ observable: Obseravble<T, U>, _ closure: Any) {
        self.observable = observable
        self.closure = closure
    }

    func dispose(in bag: DisposeBag) {
        bag.add(self)
    }

    func observe(_ closure: @escaping (T) -> Void) -> Disposable {
        _ = observable.observe(closure)
        return self
    }

    func onError(_ closure: @escaping (U) -> Void) -> Disposable {
        _ = observable.onError(closure)
        return self
    }
}

class DisposeBag {
    var disposables = NSMutableSet()
    func add(_ disposable: Any) {
        disposables.add(disposable)
    }
}
