import Mockable
import UIKit

@Mockable
protocol UIGestureRecognizing: AnyObject {
    var state: UIGestureRecognizer.State { get }
    func location(in view: UIView?) -> CGPoint
    func location(ofTouch touchIndex: Int, in view: UIView?) -> CGPoint
}

extension UIGestureRecognizer: UIGestureRecognizing {
    // No definition
}
