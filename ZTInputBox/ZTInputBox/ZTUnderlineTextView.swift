//
//  ZTUnderlineTextView.swift
//  WMS
//
//  Created by zhangtian on 2021/8/6.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import IQKeyboardManagerSwift

public extension ZTUnderlineTextView {
    static var underlineBarColor: UIColor = .black
    static var underlineBarHeight: CGFloat = 1
    static var underlineBarEditColor: UIColor = .orange
    static var underlineBarEditHeight: CGFloat = 2
    
    static var minHeight: CGFloat = 30
    static var maxHeight: CGFloat = 200
    
    static var titleFont: UIFont = .systemFont(ofSize: 16, weight: .regular)
    static var titleEditFont: UIFont = .systemFont(ofSize: 10, weight: .regular)
}

open class ZTUnderlineTextView: UIView {
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
    public lazy var minHeight: CGFloat = Self.minHeight
    public lazy var maxHeight: CGFloat = Self.maxHeight
    
    public lazy var heightChnage: Observable<Void?> = _heightChnage.asObservable()
    public lazy var textView: UITextView = .init()
    
    lazy var _lineView: UIView = .init()
    lazy var _titleLabel: ZTLabel = .init()
    lazy var _disposeBag: DisposeBag = DisposeBag()
    lazy var _heightChnage: PublishRelay<Void?> = .init()
    lazy var _tap: UITapGestureRecognizer = .init()

    open func setting() {
        textView.backgroundColor = .clear
        textView.tintColor = underlineBarEditColor
        textView.font = titleFont
        
        _titleLabel.font = titleFont
        _titleLabel.textColor = underlineBarColor
        
        _lineView.backgroundColor = underlineBarColor
        
        self.addGestureRecognizer(_tap)
    }
    open func appendUI() {
        self.addSubview(textView)
        self.addSubview(_titleLabel)
        self.addSubview(_lineView)
    }
    
    private var textViewMinHeight: CGFloat = 0
    private var constrainSize: CGSize { CGSize(width:frame.size.width,height:CGFloat(MAXFLOAT)) }
    open func layoutUI() {
        let height = textView.sizeThatFits(constrainSize).height
        textViewMinHeight = height
        
        textView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(minHeight - height)
            make.height.equalTo(height).priority(999)
        }
        _titleLabel.snp.makeConstraints { make in
            make.left.equalTo(5)
            make.centerY.equalTo(textView.snp.bottom).offset(-textViewMinHeight/2)
        }
        _lineView.snp.makeConstraints { make in
            make.left.right.equalTo(textView)
            make.bottom.equalToSuperview()
            make.height.equalTo(underlineBarHeight)
        }
        self.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(minHeight)
        }
    }

    open func handler() {
        textView.rx.setDelegate(self).disposed(by: _disposeBag)
        textView.rx.didBeginEditing.map{_ in}.bind{[weak self] in self?.startEditing()}.disposed(by: _disposeBag)
        textView.rx.didEndEditing.map{_ in}.bind{[weak self] in self?.endEditor()}.disposed(by: _disposeBag)
        textView.rx.didChange.map{_ in}.bind{[weak self] in self?.change()}.disposed(by: _disposeBag)
        textView.rx.observe(String.self, "text").bind{[weak self] _ in self?.change()}.disposed(by: _disposeBag)
        textView.rx.observe(String.self, "text").bind{[weak self] _ in self?.animationChange()}.disposed(by: _disposeBag)
        
        _tap.rx.event.bind{[weak self] rs in
            self?.textView.becomeFirstResponder()
        }.disposed(by: _disposeBag)
    }
    
    typealias LimitClosure = (String) -> Bool
    var _inputLimit: LimitClosure?
    var _titleLabelIsTop: Bool = false
    
    open func setView(_ data: Any?) {
        if let data = data as? String {
            textView.text = data
        }
    }
    
    open override func draw(_ rect: CGRect) {
        _heightChnage.accept(())
    }
}

public extension ZTUnderlineTextView {
    func startEditing() {
        _titleLabelIsTop = true
        
        _lineView.snp.updateConstraints { make in
            make.height.equalTo(underlineBarEditHeight)
        }
        _titleLabel.snp.remakeConstraints { make in
            make.left.equalTo(5)
            make.top.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.layoutIfNeeded()
            self._lineView.backgroundColor = self.underlineBarEditColor
            self._titleLabel.textColor = self.underlineBarEditColor
            
            if (self.textView.text ?? "").isEmpty {
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
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.layoutIfNeeded()
            self._lineView.backgroundColor = self.underlineBarColor
        }
        
        animationChange()
    }
    func change() {
        let constrainSize = CGSize(width:frame.size.width,height:CGFloat(MAXFLOAT))
        var height = textView.sizeThatFits(constrainSize).height
        if height < textViewMinHeight {height = textViewMinHeight}
        if height >= maxHeight {return}
        if textView.frame.size.height == height {return}
        
        textView.snp.updateConstraints { make in
            make.height.equalTo(height).priority(999)
        }
        
        _heightChnage.accept(nil)
    }
    func animationChange() {
        if textView.isFirstResponder {return}
        if (textView.text ?? "").isEmpty && _titleLabelIsTop {
            _titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(5)
                make.centerY.equalTo(textView.snp.bottom).offset(-textViewMinHeight/2)
            }
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
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
        if !(textView.text ?? "").isEmpty && !_titleLabelIsTop {
            _titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(5)
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

extension ZTUnderlineTextView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.returnKeyType == .done && text == "\n" {
            textView.resignFirstResponder()
        }
        if textView.returnKeyType == .next && text == "\n" {
            IQKeyboardManager.shared.goNext()
        }
        
        let newString = ((textView.text ?? "") as NSString).replacingCharacters(in: range, with: text)
        if newString.isEmpty {return true}
        return _inputLimit?(newString) ?? true
    }
}

