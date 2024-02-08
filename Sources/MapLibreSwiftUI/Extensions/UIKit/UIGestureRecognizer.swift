import UIKit
import Mockable

@Mockable
protocol UIGestureRecognizerProtocol: AnyObject {
    var state: UIGestureRecognizer.State { get }
    func location(in view: UIView?) -> CGPoint
    func location(ofTouch touchIndex: Int, in view: UIView?) -> CGPoint
}

extension UIGestureRecognizer: UIGestureRecognizerProtocol {
    // No definition
}
