//
//  DashboardTransitionAnimator.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 04/10/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit

class DashboardTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var type: dashboardTransitionAnimatorType
    
    init(type:dashboardTransitionAnimatorType) {
        self.type = type
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning){
        
        let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let containerView = transitionContext.containerView
        
        if type == .Present{
            // Transformation
            to?.view.frame.origin.y = -(containerView.frame.size.height + 1)
            
            //transitionContext.containerView.addSubview(to!.view)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay:0, usingSpringWithDamping:0.5, initialSpringVelocity:0.3, options:UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
                
                print("animating...")
                to?.view.frame.origin.y = 0
                
            }) { (completed) -> Void in
                print("animate completed")
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
            
        else {
            
            //transitionContext.containerView.addSubview(to!.view)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay:0, usingSpringWithDamping:300, initialSpringVelocity:0.5, options:UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
                
                print("animating...")
                from?.view.alpha = 0.0
                from?.view.frame.origin.y = containerView.frame.size.height + 300
                
            }) { (completed) -> Void in
                print("animate completed")
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
}

internal enum dashboardTransitionAnimatorType {
    case Present
    case Dismiss
}
