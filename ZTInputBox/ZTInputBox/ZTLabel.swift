//
//  ZTLabel.swift
//  WMS
//
//  Created by zhangtian on 2021/8/13.
//

import UIKit
import SnapKit

class ZTLabel: UIView {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) {super.init(coder: coder)}
    
    override func draw(_ rect: CGRect) {
        label.frame = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        self.layer.mask = label.layer
    }
    
    var textColor: UIColor {
        get {.clear}
        set {
            self.layer.backgroundColor = newValue.cgColor
        }
    }
    
    var font: UIFont? {
        get {label.font}
        set {label.font = newValue}
    }
    
    var text: String? {
        get {label.text}
        set {label.text = newValue}
    }
}
