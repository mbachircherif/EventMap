//
//  semiModalTransitionDelegate.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 23/06/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit

class RouteModalTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var viewController: UIViewController
    var presentingViewController: UIViewController
    var interactionController: SemiModalInteractiveTransition
    
    var interactiveDismiss = true
    
    init(viewController: UIViewController, presentingViewController: UIViewController) {
        
        self.viewController = viewController
        self.presentingViewController = presentingViewController
        self.interactionController = SemiModalInteractiveTransition(viewController: self.viewController, withView: self.presentingViewController.view, presentingViewController: self.presentingViewController)
        
        super.init()
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return RouteModalView(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return RouteModalTransitionAnimator(type: .Dismiss)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactiveDismiss {
            return self.interactionController
        }
        
        return nil
    }
}

extension UIViewController { }

