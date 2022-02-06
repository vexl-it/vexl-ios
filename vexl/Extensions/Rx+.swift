//
//  Rx+.swift
//  vexl
//
//  Created by Adam Salih on 06.02.2022.
//  
//

import Foundation
import RxSwift
import RxCocoa

// Originally from here:
// https://github.com/artsy/eidolon/blob/24e36a69bbafb4ef6dbe4d98b575ceb4e1d8345f/Kiosk/Observable%2BOperators.swift#L30-L40
// Credit to Artsy and @ashfurrow
public protocol _OptionalType {
    associatedtype Wrapped

    var value: Wrapped? { get }
}

extension Optional: _OptionalType {
    /// Cast `Optional<Wrapped>` to `Wrapped?`
    public var value: Wrapped? { self }
}

// Some code originally from here:
// https://github.com/artsy/eidolon/blob/24e36a69bbafb4ef6dbe4d98b575ceb4e1d8345f/Kiosk/Observable%2BOperators.swift#L42-L62
// Credit to Artsy and @ashfurrow
public extension ObservableType where Element: _OptionalType {
    /**
     Unwraps and filters out `nil` elements.
     - returns: `Observable` of source `Observable`'s elements, with `nil` elements filtered out.
     */
    func filterNil() -> Observable<Element.Wrapped> {
        return self.flatMap { element -> Observable<Element.Wrapped> in
            guard let value = element.value else {
                return Observable<Element.Wrapped>.empty()
            }
            return Observable<Element.Wrapped>.just(value)
        }
    }
}

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, Element: _OptionalType {
    public func filterNil() -> Driver<Element.Wrapped> {
        return self.flatMap { element -> Driver<Element.Wrapped> in
            guard let value = element.value else {
                return Driver<Element.Wrapped>.empty()
            }
            return Driver<Element.Wrapped>.just(value)
        }
    }
}

extension SharedSequence {
    var asVoid: SharedSequence<SharingStrategy, Void> {
        map { _ in }
    }

    var asOptional: SharedSequence<SharingStrategy, Element?> {
        map { value -> Element? in value }
    }

    func withPrevious(startWith first: Element) -> SharedSequence<SharingStrategy, (Element, Element)> {
        scan((first, first)) { ($0.1, $1) }.skip(1)
    }
}

extension PrimitiveSequence {
    func retry(max attempts: Int, delay: RxTimeInterval) -> PrimitiveSequence<Trait, Element> {
        retry { errors in
            errors
                .enumerated()
                .flatMap { index, error -> Observable<Int64> in
                    guard index <= attempts else {
                        return .error(error)
                    }
                    return .timer(delay, scheduler: MainScheduler.instance)
                }
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait {

    var asVoid: PrimitiveSequence<Trait, Void> {
        map { _ in }
    }

    var asOptional: PrimitiveSequence<Trait, Element?> {
        map { value -> Element? in value }
    }

    func catchErrorJustReturnNil() -> PrimitiveSequence<Trait, Element?> {
        asOptional.catchAndReturn(nil)
    }
}

extension ObservableType {
    var asVoid: RxSwift.Observable<Void> {
        map { _ in }
    }

    var asOptional: RxSwift.Observable<Element?> {
        map { value -> Element? in value }
    }

    func catchErrorJustReturnNil() -> Observable<Element?> {
        asOptional.catchAndReturn(nil)
    }

    func asDriverOnErrorJustComplete() -> Driver<Element> {
        asDriver { _ in Driver.empty() }
    }

    func asDriverOnErrorJustReturnNil() -> Driver<Element?> {
        asOptional.asDriver(onErrorJustReturn: nil)
    }

    func asDriverFilterNil() -> Driver<Element> {
        asDriverOnErrorJustReturnNil().filterNil()
    }

    func withPrevious(startWith first: Element) -> Observable<(Element, Element)> {
        scan((first, first)) { ($0.1, $1) }.skip(1)
    }
}

extension ObservableType where Element == Bool {
    /// Boolean not operator
    public func not() -> Observable<Bool> {
        return map(!)
    }
}

extension SharedSequenceConvertibleType where Element == Bool {
    /// Boolean not operator.
    public func not() -> SharedSequence<SharingStrategy, Bool> {
        return map(!)
    }
}

// MARK: - UIViewController

extension Reactive where Base: UIViewController {

    public var activityIndicator: Binder<RxActivityIndicator.Element> {
        return Binder(self.base) { viewController, element in
            element ? viewController.startActivity() : viewController.stopActivity()
        }
    }

    public var errors: Binder<Error> {
        return Binder(self.base) { viewController, error in
            log.info("‼️ ERROR: \((error as NSError).debugDescription) ‼️")
            viewController.handleError(error: error)
        }
    }

    public func activityIndicator(endEditing: Bool, hasBackground: Bool) -> Binder<RxActivityIndicator.Element> {
        Binder(self.base) { viewController, element in
            element ? viewController.startActivity() : viewController.stopActivity()
        }
    }

    // MARK: - Lifecycle

    public var viewDidLoad: Driver<Void> {
        sentMessage(#selector(UIViewController.viewDidLoad)).asVoid.asDriverFilterNil()
    }

    public var viewWillAppear: Driver<Void> {
        sentMessage(#selector(UIViewController.viewWillAppear(_:))).asVoid.asDriverFilterNil()
    }

    public var viewDidAppear: Driver<Void> {
        sentMessage(#selector(UIViewController.viewDidAppear(_:))).asVoid.asDriverFilterNil()
    }

    public var viewWillDisappear: Driver<Void> {
        sentMessage(#selector(UIViewController.viewWillDisappear(_:))).asVoid.asDriverFilterNil()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension UIPresentationController: HasDelegate {
    public typealias Delegate = UIAdaptivePresentationControllerDelegate
}

class UIViewControllerAdaptivePresentationDelegateProxy: DelegateProxy<UIPresentationController, UIAdaptivePresentationControllerDelegate>, DelegateProxyType, UIAdaptivePresentationControllerDelegate {

    weak private(set) var presentationController: UIPresentationController?

    init(presentationController: ParentObject) {
        self.presentationController = presentationController
        super.init(parentObject: presentationController, delegateProxy: UIViewControllerAdaptivePresentationDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { UIViewControllerAdaptivePresentationDelegateProxy(presentationController: $0) }
    }
}

extension Reactive where Base: UIPresentationController {
    var delegate: UIViewControllerAdaptivePresentationDelegateProxy {
        UIViewControllerAdaptivePresentationDelegateProxy.proxy(for: base)
    }

    var presentationControllerShouldDismiss: Observable<Void> {
        delegate
            .methodInvoked(#selector(UIAdaptivePresentationControllerDelegate.presentationControllerShouldDismiss(_:)))
            .asVoid
    }

    var presentationControllerWillDismiss: Observable<Void> {
        delegate
            .methodInvoked(#selector(UIAdaptivePresentationControllerDelegate.presentationControllerWillDismiss(_:)))
            .asVoid
    }

    var presentationControllerDidDismiss: Observable<Void> {
        delegate
            .methodInvoked(#selector(UIAdaptivePresentationControllerDelegate.presentationControllerDidDismiss(_:)))
            .asVoid
    }

    var presentationControllerDidAttemptToDismiss: Observable<Void> {
        delegate
            .methodInvoked(#selector(UIAdaptivePresentationControllerDelegate.presentationControllerDidAttemptToDismiss(_:)))
            .asVoid
    }
}
