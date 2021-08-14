//
//  RxUITextFieldDelegateProxy.swift
//  WMS
//
//  Created by zhangtian on 2021/8/9.
//

import RxSwift
import RxCocoa


class RxUITextFieldDelegateProxy: DelegateProxy<UITextField, UITextFieldDelegate>, DelegateProxyType, UITextFieldDelegate {
    init(tf: UITextField) {
        super.init(parentObject: tf, delegateProxy: RxUITextFieldDelegateProxy.self)
    }
    static func registerKnownImplementations() {
        self.register {RxUITextFieldDelegateProxy(tf: $0)}
    }
    
    static func currentDelegate(for object: UITextField) -> UITextFieldDelegate? {
        object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: UITextFieldDelegate?, to object: UITextField) {
        object.delegate = delegate
    }
}

extension Reactive where Base: UITextField {
    var delegate: RxUITextFieldDelegateProxy {
        return RxUITextFieldDelegateProxy.proxy(for: base)
    }
    
    func setDelegate(_ delegate: UITextFieldDelegate)
        -> Disposable {
        return RxUITextFieldDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
}
