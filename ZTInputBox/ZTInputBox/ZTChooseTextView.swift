//
//  ZTChooseTextView.swift
//  WMS
//
//  Created by zhangtian on 2021/8/12.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

open class ZTChooseTextView<T: ZTTitleForData>: ZTUnderlineTextView {
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
        let height = textView.sizeThatFits(constrainSize).height
        
        textView.snp.remakeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.top.equalTo(minHeight - height)
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
            textView.isEditable = data.enableEdit
            if let image = data.image {
                _chooseButton.setImage(UIImage(named: image), for: .normal)
                chooseButtonSetEvent(data: data)
            }
            textViewEditEvent(data: data)
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
        
        result.filter{ $0.isSuccess}.map{$0.data?.title}.bind(to: textView.rx.text).disposed(by: _disposeBag)
        result.filter{ $0.isSuccess}.map{$0.data}.filter{$0?.title != data.data?.title}.bind(to: data.resultData).disposed(by: _disposeBag)
        result.filter{!$0.isSuccess}.bind {[weak self] rs in
            guard let self = self else {return}
            ZTInputErrorView.show(rs.message, to: self)
        }.disposed(by: _disposeBag)
    }
    
    func textViewEditEvent(data: ZTInputBoxModel<T>) {
        if !textView.isEditable {return}
        let result = textView.rx.didEndEditing
            .map{[weak self] _ -> T? in
            if let _ = "" as? T { return self?.textView.text as? T }
            data.data?.setTitle(self?.textView.text)
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
            self.textView.text = nil
        }.disposed(by: _disposeBag)
    }
}
