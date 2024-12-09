//
//  UIView+Extensions.swift
//  OpenCap
//
//  Created by Nik on 05.09.2022.
//

import UIKit

extension UIView {
    @discardableResult
    func subviewFromNib<T: UIView>() -> T? {
        guard let view = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {
            return nil
        }

        frame = view.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)

        return view
    }
}

extension UIView {

    /**
       Rotate a view by specified degrees
       parameter angle: angle in degrees
     */

    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = CGAffineTransformRotate(self.transform, radians);
        self.transform = rotation
    }

}

