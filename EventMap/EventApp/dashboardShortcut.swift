//
//  dashboardShortcut.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 04/10/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit

class dashboardShortcut: UIView {
    
    // Implemtente it's own delegate
    weak var delegate: dashboardShortcutDelegate?
    
    var isVisible = true
    var dateShotcut : UIButton = UIButton(frame : CGRect(x: 15, y : 5, width: 60, height: 40))
    var distanceShortcut : UIButton = UIButton(frame : CGRect(x: 120, y : 5, width: 60, height: 40))
    var categoryShortcut : UIButton = UIButton(frame : CGRect(x: 240, y : 5, width: 80, height: 40))
    var shouldSetupConstraints = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 1, alpha: 1)
        self.layer.cornerRadius = 8
        
        /// dateShortcut Button
        dateShotcut.setTitle("22 SEPT.", for: .normal)
        dateShotcut.titleLabel!.font =  UIFont(name: "HelveticaNeue-Medium", size: 14)
        dateShotcut.setTitleColor(UIColor.black, for: .normal)
        dateShotcut.addTarget(self, action:#selector(showSchecule), for: .touchUpInside)
        
        /// dateShortcut Button
        distanceShortcut.setTitle("150 KM", for: .normal)
        distanceShortcut.titleLabel!.font =  UIFont(name: "HelveticaNeue-Medium", size: 14)
        distanceShortcut.setTitleColor(UIColor.black, for: .normal)
        
        /// dateShortcut Button
        categoryShortcut.setTitle("PARTY", for: .normal)
        categoryShortcut.titleLabel!.font =  UIFont(name: "HelveticaNeue-Medium", size: 14)
        categoryShortcut.setTitleColor(UIColor.black, for: .normal)
        categoryShortcut.addTarget(self, action:#selector(showCategory), for: .touchUpInside)
        
        self.addSubview(dateShotcut)
        self.addSubview(distanceShortcut)
        self.addSubview(categoryShortcut)
        setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func updateConstraints() {
        if(shouldSetupConstraints) {
            // AutoLayout constraints
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
    
    /// MARK - Shortcut functions
    func showSchecule(){
        let vc = scheduleViewController()
        delegate?.presentDashbord(vc)
    }
    
    func showCategory(){
        let vc = categoryViewController()
        delegate?.presentDashbord(vc)
    }
    
    func setVisible(){
        
    }
    
}

protocol dashboardShortcutDelegate: class {
    func presentDashbord(_ vc: UIViewController)
}
