//
//  ZTInputErrorView.swift
//  WMS
//
//  Created by zhangtian on 2021/8/6.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

public extension ZTInputErrorView {
    static var textAlignment: NSTextAlignment = .center
    static var numberOfLines: Int = 0
    static var font: UIFont = .systemFont(ofSize: 14, weight: .medium)
    static var textColor: UIColor = .white
    static var color: UIColor = .init(white: 0, alpha: 0.8)
    static var cornerRadius: CGFloat = 2
    static var edges: UIEdgeInsets = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
    static var dwellTime: CGFloat = 2
    static var hiddenAnimationDuration: CGFloat = 0.1
}

public class ZTInputErrorView: UIView {
    public required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setting()
        appendUI()
        layoutUI()
    }
    lazy var msgLabel: UILabel = {
        let l = UILabel()
        l.font = Self.font
        l.textColor = Self.textColor
        l.textAlignment = Self.textAlignment
        l.numberOfLines = Self.numberOfLines
        return l
    }()
    
    func setting() {
        self.layer.cornerRadius = Self.cornerRadius
        self.backgroundColor = Self.color
    }
    func appendUI() {
        self.addSubview(msgLabel)
    }
    func layoutUI() {
        msgLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Self.edges)
        }
    }
}

public extension ZTInputErrorView {
    func show(_ msg: String?, to view: UIView) {
        view.addSubview(self)
        
        self.msgLabel.text = msg
        self.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+Double(Self.dwellTime)) {
            self.hidden()
        }
    }
    
    func hidden() {
        UIView.animate(withDuration: TimeInterval(Self.hiddenAnimationDuration), animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
            self.alpha = 1
        })
    }
    
    
    class func show(_ msg: String?, to view: UIView) {
        let errorView = ZTInputErrorView()
        errorView.msgLabel.text = msg
        view.addSubview(errorView)
        errorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+Double(Self.dwellTime)) {
            hidden(errorView)
        }
    }
    
    class func hidden(_ errorView: UIView) {
        UIView.animate(withDuration: TimeInterval(Self.hiddenAnimationDuration), animations: {
            errorView.alpha = 0
        }, completion: { _ in
            errorView.removeFromSuperview()
            errorView.alpha = 1
        })
    }
}
