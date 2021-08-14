//
//  ZTChooseInputView.swift
//  WMS
//
//  Created by zhangtian on 2021/8/12.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

open class ZTChooseInputView<T: ZTTitleForData>: ZTUnderlineInputView {
    lazy var _chooseButton: UIButton = {
        let bt = UIButton()
        return bt
    }()
    
    open override func appendUI() {
        super.appendUI()
        
        self.addSubview(_chooseButton)
    }
    open override func layoutUI() {
        super.layoutUI()
        
        let constrainSize = CGSize(width:frame.size.width,height:CGFloat(MAXFLOAT))
        let height = textField.sizeThatFits(constrainSize).height + 14
        
        textField.snp.remakeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.height.equalTo(height).priority(999)
            make.right.equalTo(_chooseButton.snp.left).offset(-10)
        }
        _chooseButton.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.width.equalTo(45)
            make.height.equalTo(45)
        }
    }
    
    open override func setView(_ data: Any?) {
        super.setView(data)
        
        if let data = data as? ZTInputBoxModel<T> {
            _inputLimit = data.inputLimit
            _titleLabel.text = data.title
            
            textField.isEnabled = data.enableEdit
            if let image = data.image {
                _chooseButton.setImage(UIImage(named: image), for: .normal)
                chooseButtonSetEvent(data: data)
            }
            textFieldEditEvent(data: data)
        }
    }
    
    func chooseButtonSetEvent(data: ZTInputBoxModel<T>) {
        let result = _chooseButton.rx.tap.map{_ in}
            .filter{data.chooseAction != nil}
            .flatMapLatest{data.chooseAction!()}
            .map{ rs -> ZTResult<T> in
                if let checkAction = data.checkAction {
                    return checkAction(rs?.title)
                }
                return .success(rs)
            }.share()
        
        result.filter{ $0.isSuccess}.map{$0.data?.title}.bind(to: textField.rx.text).disposed(by: _disposeBag)
        result.filter{ $0.isSuccess}.map{$0.data}.filter{$0?.title != data.data?.title}.bind(to: data.resultData).disposed(by: _disposeBag)
        result.filter{!$0.isSuccess}.bind {[weak self] rs in
            guard let self = self else {return}
            ZTInputErrorView.show(rs.message, to: self)
        }.disposed(by: _disposeBag)
    }
    
    func textFieldEditEvent(data: ZTInputBoxModel<T>) {
        if !textField.isEnabled {return}
        let result = textField.rx.controlEvent(.editingDidEnd)
            .map{[weak self] _ -> T? in
            if let _ = "" as? T { return self?.textField.text as? T }
                data.data?.setTitle(self?.textField.text)
                return data.data
            }
            .map{ rs -> ZTResult<T> in
                if let checkAction = data.checkAction {
                    return checkAction(rs?.title)
                }
                return .success(rs)
            }.share()
        
        result.filter{ $0.isSuccess}.map{$0.data}.filter{$0?.title != data.data?.title}.bind(to: data.resultData).disposed(by: _disposeBag)
        result.filter{!$0.isSuccess}.bind {[weak self] rs in
            guard let self = self else {return}
            ZTInputErrorView.show(rs.message, to: self)
            self.textField.text = nil
        }.disposed(by: _disposeBag)
    }
}
