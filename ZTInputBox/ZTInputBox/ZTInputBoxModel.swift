//
//  ZTInputBoxModel.swift
//  WMS
//
//  Created by zhangtian on 2021/8/12.
//

import Foundation
import RxCocoa
import RxSwift

public enum ZTResult<T> {
    case success(T?)
    case failure(String)
    
    public var message: String? {
        switch self {
        case .success:
            return nil
        case .failure(let message):
            return message
        }
    }
    public var data: T? {
        switch self {
        case .success(let data):
            return data
        case .failure:
            return nil
        }
    }
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}

public protocol ZTTitleForData {
    var title: String {get}
    func setTitle(_ title: String?)
}
public extension ZTTitleForData {
    func setTitle(_ title: String?) {}
}
extension String: ZTTitleForData {
    public var title: String {self}
}

public class ZTInputBoxModel<T: ZTTitleForData> {
    public typealias ChooseClosure = () -> Observable<T?>
    public typealias CheckClosure = (String?) -> ZTResult<T>
    public typealias LimitClosure = (String) -> Bool
    
    public var title: String?
    public var image: String?
    public var enableEdit: Bool = true
    public var chooseAction: ChooseClosure?
    public var checkAction: CheckClosure?
    public var inputLimit: LimitClosure?
    
    var resultData: BehaviorRelay<T?> = .init(value: nil)
    public var data: T? {return resultData.value}
    public var result: Observable<T>
    
    public init(title: String, image: String? = nil, enableEdit: Bool = true, chooseAction: ChooseClosure? = nil, checkAction: CheckClosure? = nil, inputLimit: LimitClosure? = nil) {
        self.title = title
        self.image = image
        self.enableEdit = enableEdit
        self.chooseAction = chooseAction
        self.checkAction = checkAction
        self.inputLimit = inputLimit
        self.result = resultData.filter{$0 != nil}.map{$0!}.asObservable()
    }
}
