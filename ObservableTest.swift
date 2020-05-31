import Foundation

class Observer<T> {
    let closure: (T) -> Void
    init(_ closure: @escaping (T) -> Void) {
        self.closure = closure
    }

    deinit {
        print("deinit: \(self)")
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

    deinit {
        print("deinit: \(self)")
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

    deinit {
        print("deinit: \(self)")
    }
}

class DisposeBag {
    var disposables = NSMutableSet()
    func add(_ disposable: Disposable) {
        disposables.add(disposable)
    }

    func empty() {
        disposables = []
    }

    deinit {
        print("deinit: \(self)")
    }
}


print("creating bag1")
let bag1 = DisposeBag()

print("creating bag2")
let bag2 = DisposeBag()

print("creating dispatch queue")
let q = DispatchQueue(label: "q")


func observeStuff(_ a: @escaping ((String) -> Void), _ b: @escaping ((String) -> Void)) {
    print("begin observeStuff")

    print("creating observable")
    let observable: Observable<String>? = Observable<String>()

    print("scheduling next values on dispatch queue")
    q.asyncAfter(deadline: DispatchTime.now() + 1) {
        print("\n...dispatched")

        print("if observation is occurring, next line should be 'abc'")
        observable?.next("abc")

        print("if observation is occurring, next line should be 'def'")
        observable?.next("def")
    }

    print("observing with closure a, disposing in bag 1")
    observable?.observe(a).dispose(in: bag1)

    print("observing with closure b, disposing in bag 2")
    observable?.observe(b).dispose(in: bag2)

    print("end observeStuff, observable exiting scope")
}


print("calling observeStuff with two closures")
observeStuff(
    { print("closure a,bag1 observed: \($0)") },
    { print("closure b,bag2 observed: \($0)") }
    )

print("emptying bag1. observations should only run once now")
bag1.empty()

print("scheduling empty of bag 2")
q.asyncAfter(deadline: DispatchTime.now() + 2) {
    print("\nemptying bag2. remaining stuff should now deinit")
    bag2.empty()
}

print("running runloop")
CFRunLoopRun()

print("if this gets printed something is wrong")
