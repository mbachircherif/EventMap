//
//  DashboardPresentationController.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 04/10/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit

class DashboardPresentationController: UIPresentationController {
    
    var isMaximized: Bool = false
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
    //let frame = UIScreen.main.bounds
    
    var _dimmingView: UIView?
    var dimmingView: UIView {
        if let dimmedView = _dimmingView {
            return dimmedView
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height))
        
        // Blur Effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.5
        blurEffectView.frame = view.bounds
        
        //let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        //let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        //vibrancyEffectView.frame = view.bounds
        
        // Add the vibrancy view to the blur view
        //blurEffectView.contentView.addSubview(vibrancyEffectView)
        view.addSubview(blurEffectView)
        
        _dimmingView = view
        
        return view
    }
    
    func dimmingViewTapped(tapRecognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        return CGRect(x: 0 , y: 0 , width: containerView!.bounds.width * 1, height: containerView!.bounds.height * 0.6)
    }
    
    override func containerViewWillLayoutSubviews() {
        
        presentedView?.layer.cornerRadius = 12.0
        presentedView?.clipsToBounds = true
        dimmingView.addGestureRecognizer(tapRecognizer)
        
    }
    override func containerViewDidLayoutSubviews() {
        
        // Add Tap Gestur on Dimming View to Dismiss
        
    }
    
    // When the presentation Controller while be presenting
    override func presentationTransitionWillBegin() {
        //let dimmedView = dimmingView
        
        if let containerView = self.containerView, let coordinator = presentingViewController.transitionCoordinator {
            
            dimmingView.alpha = 0
            containerView.addSubview(dimmingView)
            dimmingView.addSubview(presentedViewController.view)
            
            coordinator.animate(alongsideTransition: { (context) -> Void in
                self.dimmingView.alpha = 1
                self.presentedViewController.view.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentingViewController.transitionCoordinator {
            
            coordinator.animate(alongsideTransition: { (context) -> Void in
                self.dimmingView.alpha = 0
            }, completion: { (completed) -> Void in
                print("done dismiss animation")
            })
            
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        print("dismissal did end: \(completed)")
        
        if completed {
            dimmingView.removeFromSuperview()
            _dimmingView = nil
            
            isMaximized = false
        }
    }
}

/*protocol SemiModalPresentable { }

extension SemiModalPresentable where Self: UIViewController {
    func maximizeToFullScreen() -> Void {
        if let presentation = navigationController?.presentationController as? SemiModalView {
            presentation.adjustToFullScreen()
        }
    }
}

extension SemiModalPresentable where Self: UINavigationController {
    func isSemiModalMaximized() -> Bool {
        if let presentationController = presentationController as? SemiModalView {
            return presentationController.isMaximized
        }
        
        return false
    }
*/
