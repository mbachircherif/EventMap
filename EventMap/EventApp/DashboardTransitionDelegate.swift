//
//  DashboardTransitionDelegate.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 04/10/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit

class DashboardTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var viewController: UIViewController
    var presentingViewController: UIViewController
    
    init(viewController: UIViewController, presentingViewController: UIViewController) {
        
        self.viewController = viewController
        self.presentingViewController = presentingViewController
        
        super.init()
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DashboardPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DashboardTransitionAnimator(type: .Dismiss)
    }
    
    /*func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
     return SemiModalTransitionAnimator(type: .Present)
     }*/
    
}

extension UIViewController { }
