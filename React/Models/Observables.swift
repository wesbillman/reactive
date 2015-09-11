//
//  Observables.swift
//  WatchIt
//
//  Created by Alec Thomas on 8/09/2015.
//  Copyright © 2015 SwapOff. All rights reserved.
//

import Foundation
import RxSwift

public protocol ObservableEvent {}

public protocol ObservableStructure {
    var propertyChanged: Observable<String> { get }
}

public enum ObservableCollectionEvent<Element>: ObservableEvent {
    case Inserted(location:Int, element: Element)
    case AddedRange(range: Range<Int>, elements: [Element])
    case Removed(location: Int, element: Element)
    case RemovedRange(range: Range<Int>, elements: [Element])
}

public func  == <T: Equatable>(a: ObservableCollectionEvent<T>, b: ObservableCollectionEvent<T>) -> Bool {
    switch a {
    case let .Inserted(al, ae):
        if case let .Inserted(bl, be) = b { return al == bl && ae == be }
    case let .AddedRange(ar, ae):
        if case let .AddedRange(br, be) = b { return ar == br && ae == be }
    case let .Removed(al, ae):
        if case let .Removed(bl, be) = b { return al == bl && ae == be }
    case let .RemovedRange(ar, ae):
        if case let .RemovedRange(br, be) = b { return ar == br && ae == be }
    }
    return false
}

// Extend ObservableCollection to allow observation of element changes
// iff the Element is an ObservableStructure.
public extension ObservableCollection where Element: ObservableStructure {
    public var elementChanged: Observable<(Element, String)> {
        let publisher = PublishSubject<(Element, String)>()
        for element in self {
            element.propertyChanged.map({n in (element, n)}).subscribe(publisher)
        }
        return publisher
    }
    
    public var anyChange: Observable<Void> {
        return sequenceOf(
            // Check changed elements for validity.
            elementChanged
                .map({(i, _) in
                    return true
                })
                .filter({$0})
                .map({_ in ()}),
            collectionChanged.map({_ in ()})
            ).merge()
    }
}

// An Array-ish object that is observable.
public class ObservableCollection<Element>: CollectionType, ArrayLiteralConvertible {
    public let collectionChanged = PublishSubject<ObservableCollectionEvent<Element>>()
    
    private var source: [Element]
    
    public var count: Int { return source.count }
    public var startIndex: Int { return source.startIndex }
    public var endIndex: Int { return source.endIndex }
    
    public init() {
        self.source = []
    }
    
    public init(source: [Element]) {
        self.source = source
    }
    
    deinit {
        collectionChanged.on(.Completed)
        collectionChanged.dispose()
    }
    
    public required init(arrayLiteral elements: Element...) {
        self.source = elements
    }
    
    public func append(element: Element) {
        source.append(element)
        collectionChanged.on(.Next(.Inserted(location: count - 1, element: element)))
    }
    
    public func removeAll() {
        let elements = source
        source.removeAll()
        collectionChanged.on(.Next(.RemovedRange(range: Range(start: source.startIndex, end: source.endIndex), elements: elements)))
    }
    
    public func removeAtIndex(index: Int) -> Element {
        let element = source.removeAtIndex(index)
        collectionChanged.on(.Next(.Removed(location: index, element: element)))
        return element
    }
    
    public func removeFirst() -> Element {
        let element = source.removeFirst()
        collectionChanged.on(.Next(.Removed(location: 0, element: element)))
        return element
    }
    
    public func removeLast() -> Element {
        let element = source.removeLast()
        collectionChanged.on(.Next(.Removed(location: count + 1, element: element)))
        return element
    }
    
    public func insert(element: Element, atIndex i: Int) {
        source.insert(element, atIndex: i)
        collectionChanged.on(.Next(.Inserted(location: i, element: element)))
    }
    
    public func appendContentsOf<S : SequenceType where S.Generator.Element == Element>(newElements: S) {
        let index = source.count
        let elements = Array(newElements)
        source.appendContentsOf(newElements)
        collectionChanged.on(.Next(.AddedRange(range: Range(start: index, end: index+elements.count), elements: elements)))
    }
    
    public func replaceRange<C : CollectionType where C.Generator.Element == Element>(range: Range<Int>, with elements: C) {
        let old = Array(source[range])
        let new = Array(elements)
        source.replaceRange(range, with: elements)
        collectionChanged.on(.Next(.RemovedRange(range: range, elements: old)))
        collectionChanged.on(.Next(.AddedRange(range: Range(start: range.startIndex, end: range.endIndex), elements: new)))
    }
    
    public func popLast() -> Element? {
        return source.count == 0 ? nil : removeLast()
    }
    
    public subscript(index: Int) -> Element {
        get {
            return source[index]
        }
        set(value) {
            let old = source[index]
            source[index] = value
            collectionChanged.on(.Next(.Removed(location: index, element: old)))
            collectionChanged.on(.Next(.Inserted(location: index, element: value)))
        }
    }
    
    public subscript(range: Range<Int>) -> ArraySlice<Element> {
        get {
            return source[range]
        }
        set(value) {
            let old = Array(source[range])
            source[range] = value
            collectionChanged.on(.Next(.RemovedRange(range: range, elements: old)))
            collectionChanged.on(.Next(.AddedRange(range: Range(start: range.startIndex, end: range.startIndex), elements: Array(value))))
        }
    }
}