public protocol MLNRawRepresentable<T> {
    associatedtype T: RawRepresentable

    var mlnRawValue: T { get }
}
