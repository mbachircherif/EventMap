//
//  semiModalTransitionAnimator.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 23/06/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//
//http://mathewsanders.com/custom-menu-transitions-in-swift/


import UIKit

class SemiModalTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var type: semiModalTransitionAnimatorType
    
    init(type:semiModalTransitionAnimatorType) {
        self.type = type
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning){
        
        let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let containerView = transitionContext.containerView
        
        if type == .Present{
            // Transformation
            //to?.view.frame.origin.y = containerView.frame.size.height + 1
            //to?.view.layer.cornerRadius = 12.0
            //to?.view.clipsToBounds = true
            
            //transitionContext.containerView.addSubview(to!.view)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay:0, usingSpringWithDamping:0.5, initialSpringVelocity:0.3, options:UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
                
                print("animating...")
                //to?.view.frame.origin.y = 800
                
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
                    from?.view.frame.origin.y = containerView.frame.size.height + 1
                    
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

internal enum semiModalTransitionAnimatorType {
    case Present
    case Dismiss
}
