//
//  BottomActivityView.swift
//  OpenCap
//
//  Created by Nik on 15.09.2022.
//

import UIKit

protocol BottomActivityViewDelegate: AnyObject {
    func didTapActionButton()
}

class BottomActivityView: UIView {

     var actionsButton: UIButton?
     var logoImageView: UIImageView?
    
    weak var delegate: BottomActivityViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame:frame)

        actionsButton = UIButton(frame: CGRect(x: 20, y: 40, width: 35, height: 35))
        actionsButton?.setImage(UIImage(named: "gear.circle"), for: .normal)
        actionsButton?.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        actionsButton?.tintColor = .white
        addSubview(actionsButton!)
        actionsButton?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        actionsButton?.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        
        logoImageView = UIImageView(frame: CGRect(x: self.frame.width - 60, y: 40, width: 40, height: 40))
        logoImageView?.image = UIImage(named: "OpenCapIcon")
        addSubview(logoImageView!)
        logoImageView?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 20).isActive = true
        logoImageView?.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        
        backgroundColor = .clear
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func tapAction() {
        delegate?.didTapActionButton()
    }
}
