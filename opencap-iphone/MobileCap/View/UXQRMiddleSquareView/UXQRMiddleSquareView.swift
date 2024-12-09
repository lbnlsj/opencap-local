//
//  UXQRMiddleSquareView.swift
//  OpenCap
//
//  Created by Nik on 02.09.2022.
//

import UIKit

class UXQRMiddleSquareView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet private var cornerViews
    : [UIView]!
        
    // MARK: - View initializing
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        subviewFromNib()
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        subviewFromNib()
        setup()
    }
    
    // MARK: - Private methods
    func setup() {
        backgroundColor = .clear
        cornerViews.forEach({
            $0.backgroundColor = .white
        })
    }
    
}
