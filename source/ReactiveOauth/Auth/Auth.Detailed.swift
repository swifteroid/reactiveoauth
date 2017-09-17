import Foundation
import ReactiveSwift
import WebKit

public protocol DetailedAuthReactiveExtensionsProvider
{
    associatedtype DetailType
}

open class DetailedAuth<Detail>: DetailedAuthReactiveExtensionsProvider
{
    public typealias DetailType = Detail

    open let detalisator: Detalisator<Detail>

    public init(detalisator: Detalisator<Detail>) {
        self.detalisator = detalisator
    }

    // MARK: -

    internal let pipe = Signal<(Credential, Detail), Error>.pipe()
}

// MARK: -

public struct DetailedAuthUrl
{
    public let detail: String
    public init(detail: String) {
        self.detail = detail
    }
}

// MARK: -

extension DetailedAuthReactiveExtensionsProvider
{
    public var reactive: DetailedAuthReactive<Self, DetailType> {
        return DetailedAuthReactive(self)
    }
}

public struct DetailedAuthReactive<Base, Detail>
{
    public let base: Base

    fileprivate init(_ base: Base) {
        self.base = base
    }
}