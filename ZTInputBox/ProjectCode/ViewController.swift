//
//  ViewController.swift
//  ZTInputBox
//
//  Created by zhangtian on 2021/8/13.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    lazy var tf01: ZTChooseTextView<String> = {
        ZTChooseTextView<String>.minHeight = 60
        let tf = ZTChooseTextView<String>()
        return tf
    }()
    lazy var tf02: ZTChooseInputView<String> = {
        let tf = ZTChooseInputView<String>()
        return tf
    }()
    lazy var tableView: UITableView = {
        let tb = UITableView()
        tb.separatorStyle = .none
        tb.backgroundColor = .lightGray
        return tb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appendUI()
        layoutUI()
        handler()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    func appendUI() {
        self.view.addSubview(tableView)
    }
    func layoutUI() {
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(44)
            make.height.equalTo(60)
        }
        
        tableView.rx.addCells(from: [tf01, tf02]) { ip, make in
            make.edges.equalToSuperview()
        }.disposed(by: disposeBag)
        
        tf02.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
    func handler() {
        let chooseBlock: () -> Observable<String?> = {Observable.of("箱号01")}
        let checkBlock01: (String?) -> ZTResult<String> = { rs in
            return .success(rs)
        }
        let checkBlock02: (String?) -> ZTResult<String> = { rs in
            if (rs ?? "").isEmpty {return .success(nil)}
            return .failure("！！！输入格式错误！！！")
        }
        let limitBlock: (String) -> Bool = {[weak self] rs in
            self?.isValid(rs, regex: "^[0-9]+(\\.[0-9]{0,3})?$") ?? true
        }
        
        //let m1 = ZTInputBoxModel<String>(title: "箱号", image: "ic_scan", chooseAction: block01, checkAction: block03, inputLimit: nil)
        let m1 = ZTInputBoxModel<String>(title: "箱号", image: "ic_scan", chooseAction: chooseBlock, checkAction: checkBlock01, inputLimit: nil)
        let m2 = ZTInputBoxModel<String>(title: "库位号", image: "ic_scan", chooseAction: chooseBlock, checkAction: checkBlock02, inputLimit: limitBlock)
        
        m1.result.bind{ rs in
            print(rs)
        }.disposed(by: disposeBag)
        m2.result.bind{ rs in
            print(rs)
        }.disposed(by: disposeBag)
        
        tf01.setView(m1)
        tf02.setView(m2)
        
        tf01.heightChnage.map{_ in}.bind(to: tableView.rx.updateBinder).disposed(by: disposeBag)
        tf01.heightChnage.map{[weak self] _ -> CGFloat? in
            guard let height = self?.tf02.superview?.superview?.frame.size.height,
                  let y = self?.tf02.superview?.superview?.frame.origin.y else {return nil}
            return height + y
        }
        .bind(to: tableView.rx.updateHeightBinder)
        .disposed(by: disposeBag)
    }
    
    func isValid(_ checkStr: String, regex: String) -> Bool {
        let predicte = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicte.evaluate(with: checkStr)
    }
}


extension Reactive where Base: UITableView {
    var updateBinder: Binder<()> {
        return Binder(self.base) { ws, _ in
            UIView.setAnimationsEnabled(false)
            ws.beginUpdates()
            ws.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    var updateHeightBinder: Binder<CGFloat?> {
        return Binder(self.base) { ws, height in
            guard let height = height else {return}
            ws.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
        }
    }
    
    func addCells(from views: [UIView], layout: @escaping (Int, ConstraintMaker)->()) -> Disposable {
        let ob = Observable.of(views)
        
        return ob.bind(to: self.items) { tb, ip, item in
            if let cell = tb.dequeueReusableCell(withIdentifier: "cell") {
                cell.contentView.subviews.forEach{$0.removeFromSuperview()}
                cell.contentView.addSubview(item)
                item.snp.makeConstraints { make in
                    layout(ip, make)
                }
                return cell
            }
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.contentView.subviews.forEach{$0.removeFromSuperview()}
            cell.contentView.addSubview(item)
            item.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            return cell
        }
    }
}
