//
//  JHTabBar.swift
//  JHTabBarController
//
//  Created by iOS on 2020/6/2.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit
import SnapKit
public class JHTabBar: UITabBar {

    private var buttons: [JHTabBarItemContentView] = []

     public override var selectedItem: UITabBarItem? {
        willSet {
            guard let newValue = newValue else {
                buttons.forEach { $0.select(false) }
                return
            }
            guard let index = items?.firstIndex(of: newValue),
                index != NSNotFound else {
                    return
            }
            select(itemAt: index, animated: false)
        }
    }
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    var container: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private func configure() {
//        backgroundColor = UIColor.white
//        isTranslucent = false
//        barTintColor = UIColor.white
//        tintColor = #colorLiteral(red: 0.1176470588, green: 0.1176470588, blue: 0.431372549, alpha: 1)
        addSubview(container)
        let bottomOffset: CGFloat
        if #available(iOS 11.0, *) {
            bottomOffset = safeAreaInsets.bottom
        } else {
            bottomOffset = 0
        }
        container.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-bottomOffset)
        }

    }
    
    override public func safeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.safeAreaInsetsDidChange()
            container.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview().offset(-safeAreaInsets.bottom)
            }
        } else { }
    }
    
    public override func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        super.setItems(items, animated: animated)
        reloadViews()
    }
    
    private func reloadViews() {
        subviews.filter { String(describing: type(of: $0)) == "UITabBarButton" }.forEach { $0.removeFromSuperview() }
        buttons.forEach { $0.removeFromSuperview() }
        buttons = items?.map { self.button(forItem: $0 as! JHTabBarItem) } ?? []
        var lastButton : JHTabBarItemContentView?
        let itemWidth = (self.bounds.width - 20) / CGFloat(buttons.count)
        buttons.forEach { (button) in
            self.container.addSubview(button)
            button.snp.remakeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(itemWidth)
                if let last = lastButton{
                    make.left.equalTo(last.snp.right)
                }else{
                    make.left.equalToSuperview()
                }
            }
            lastButton = button
        }

        layoutIfNeeded()
    }
    
    private func button(forItem item: JHTabBarItem) -> JHTabBarItemContentView {
        guard let button = item.contentView else {
            fatalError("items must inherit JHTabBarItem")
        }
        button.addTarget(self, action: #selector(btnPressed), for: .touchUpInside)
        if selectedItem != nil && item === selectedItem {
            button.select()
        }
        item.configContentView()
        return button
    }
    
    @objc private func btnPressed(sender: JHTabBarItemContentView) {
        guard let index = buttons.firstIndex(of: sender),
            index != NSNotFound,
            let item = items?[index] else {
                return
        }
        buttons.forEach { (button) in
            guard button != sender else {
                return
            }
            button.deselect()
        }
        sender.select()

        delegate?.tabBar?(self, didSelect: item)
    }
    
    func select(itemAt index: Int, animated: Bool = false) {
        guard index < buttons.count else {
            return
        }
        let selectedbutton = buttons[index]
        buttons.forEach { (button) in
            guard button != selectedbutton else {
                return
            }
            button.deselect(animated: false)
        }
        selectedbutton.select(animated: false)
    }
    

}