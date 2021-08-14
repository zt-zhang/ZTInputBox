//
//  ZTUnderlineInputView.swift
//  WMS
//
//  Created by zhangtian on 2021/8/6.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import IQKeyboardManagerSwift

public extension ZTUnderlineInputView {
    static var underlineBarColor: UIColor = .black
    static var underlineBarHeight: CGFloat = 1
    static var underlineBarEditColor: UIColor = .orange
    static var underlineBarEditHeight: CGFloat = 2
    
    static var leftSpacing: CGFloat = 5
    
    static var titleFont: UIFont = .systemFont(ofSize: 16, weight: .regular)
    static var titleEditFont: UIFont = .systemFont(ofSize: 10, weight: .regular)
}

open class ZTUnderlineInputView: UIView {
    public required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setting()
        appendUI()
        layoutUI()
        handler()
    }
    
    public lazy var underlineBarColor: UIColor = Self.underlineBarColor
    public lazy var underlineBarHeight: CGFloat = Self.underlineBarHeight
    public lazy var underlineBarEditColor: UIColor = Self.underlineBarEditColor
    public lazy var underlineBarEditHeight: CGFloat = Self.underlineBarEditHeight
    public lazy var titleFont: UIFont = Self.titleFont
    public lazy var titleEditFont: UIFont = Self.titleEditFont
    public lazy var leftSpacing: CGFloat = Self.leftSpacing
    
    public lazy var textField: UITextField = .init()
    
    lazy var _lineView: UIView = .init()
    lazy var _titleLabel: ZTLabel = .init()
    lazy var _leftView: UIView = .init()
    lazy var _disposeBag: DisposeBag = DisposeBag()
    lazy var _tap: UITapGestureRecognizer = .init()
    
    open func setting() {
        textField.leftViewMode = .always
        textField.leftView = _leftView
        textField.tintColor = underlineBarEditColor
        
        _titleLabel.font = titleFont
        _titleLabel.textColor = underlineBarColor
        
        _leftView.frame = .init(x: 0, y: 0, width: leftSpacing, height: 30)
        _lineView.backgroundColor = underlineBarColor
        
        addGestureRecognizer(_tap)
    }
    open func appendUI() {
        self.addSubview(textField)
        self.addSubview(_titleLabel)
        self.addSubview(_lineView)
    }
    private var constrainSize: CGSize { CGSize(width:self.frame.size.width,height:CGFloat(MAXFLOAT)) }
    private var textFieldHeight: CGFloat = 0
    open func layoutUI() {
        let height = textField.sizeThatFits(constrainSize).height + 14
        textFieldHeight = height
        
        textField.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(height).priority(999)
        }
        _titleLabel.snp.makeConstraints { make in
            make.left.equalTo(leftSpacing)
            make.centerY.equalTo(textField.snp.bottom).offset(-textFieldHeight/2)
        }
        _lineView.snp.makeConstraints { make in
            make.left.right.equalTo(textField)
            make.bottom.equalToSuperview()
            make.height.equalTo(underlineBarHeight)
        }
    }

    open func handler() {
        textField.rx.setDelegate(self).disposed(by: _disposeBag)
        textField.rx.controlEvent(.editingDidBegin).map{_ in}.bind{[weak self] in self?.startEditing()}.disposed(by: _disposeBag)
        textField.rx.controlEvent(.editingDidEnd).map{_ in}.bind{[weak self] in self?.endEditor()}.disposed(by: _disposeBag)
        textField.rx.observe(String.self, "text").bind{[weak self] _ in self?.animationChange()}.disposed(by: _disposeBag)
        
        _tap.rx.event.bind{[weak self] rs in
            self?.textField.becomeFirstResponder()
        }.disposed(by: _disposeBag)
    }
    
    typealias LimitClosure = (String) -> Bool
    var _inputLimit: LimitClosure?
    var _titleLabelIsTop: Bool = false
    
    open func setView(_ data: Any?) {
        if let data = data as? String {
            textField.text = data
        }
    }
}

public extension ZTUnderlineInputView {
    func startEditing() {
        _titleLabelIsTop = true
        
        _lineView.snp.updateConstraints { make in
            make.height.equalTo(underlineBarEditHeight)
        }
        _titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(leftSpacing)
            make.top.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.layoutIfNeeded()
            self._lineView.backgroundColor = self.underlineBarEditColor
            self._titleLabel.textColor = self.underlineBarEditColor
            
            if (self.textField.text ?? "").isEmpty {
                let width = self._titleLabel.sizeThatFits(self.constrainSize).width
                let scale = self.titleEditFont.lineHeight/self.titleFont.lineHeight
                let x = (width*scale-width)/2
                let y = (self.titleEditFont.lineHeight - self.titleFont.lineHeight)/2
                
                let transform = CGAffineTransform(translationX: x, y: y)
                self._titleLabel.transform = transform.scaledBy(x: scale, y: scale)
            }
        } completion: { _ in
            self._titleLabel.transform = .identity
            self._titleLabel.font = self.titleEditFont
        }
    }
    func endEditor() {
        _lineView.snp.updateConstraints { make in
            make.height.equalTo(underlineBarHeight)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.layoutIfNeeded()
            self._lineView.backgroundColor = self.underlineBarColor
        }
    }
    func animationChange() {
        if textField.isEditing {return}
        if (textField.text ?? "").isEmpty && _titleLabelIsTop {
            _titleLabelIsTop = false
            _titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(leftSpacing)
                make.centerY.equalTo(textField.snp.bottom).offset(-textFieldHeight/2)
            }
            
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                self.layoutIfNeeded()
                self._titleLabel.textColor = self.underlineBarColor
                
                
                let width = self._titleLabel.sizeThatFits(self.constrainSize).width
                let scale = self.titleFont.lineHeight/self.titleEditFont.lineHeight
                let x = (width*scale-width)/2
                
                let transform = CGAffineTransform(translationX: x, y: 0)
                self._titleLabel.transform = transform.scaledBy(x: scale, y: scale)
                
            } completion: { _ in
                self._titleLabel.transform = .identity
                self._titleLabel.font = self.titleFont
            }
        }
        if !(textField.text ?? "").isEmpty && !_titleLabelIsTop {
            _titleLabelIsTop = true
            _titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(leftSpacing)
                make.top.equalToSuperview()
            }
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
                self.layoutIfNeeded()
                self._titleLabel.textColor = self.underlineBarEditColor
                
                
                let width = self._titleLabel.sizeThatFits(self.constrainSize).width
                let scale = self.titleEditFont.lineHeight/self.titleFont.lineHeight
                let x = (width*scale-width)/2
                let y = (self.titleEditFont.lineHeight - self.titleFont.lineHeight)/2
                
                let transform = CGAffineTransform(translationX: x, y: y)
                self._titleLabel.transform = transform.scaledBy(x: scale, y: scale)
            } completion: { _ in
                self._titleLabel.transform = .identity
                self._titleLabel.font = self.titleEditFont
            }
        }
    }
}

extension ZTUnderlineInputView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            IQKeyboardManager.shared.goNext()
        }
        textField.resignFirstResponder()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        if newString.isEmpty {return true}
        return _inputLimit?(newString) ?? true
    }
}

