//
//  TransitionAnimator.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/31.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import UIKit
import CoreGraphics

class PresentAnimator: NSObject,UIViewControllerAnimatedTransitioning {
    
    let duration = 0.2 
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containView = transitionContext.containerView
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        fromView.isHidden = true
        toView.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
        
        containView.addSubview(toView)
        UIView.animate(withDuration: duration, animations: { () -> Void in
            toView.transform = CGAffineTransform.identity
            fromView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        }) { (finished) -> Void in
            transitionContext.completeTransition(true)
        }
    }
}

class DismisssAnimator:NSObject,UIViewControllerAnimatedTransitioning {
    
    let duration = 0.2
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containView = transitionContext.containerView
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        toView.isHidden = false
        fromView.isHidden = true
        containView.addSubview(toView)
        containView.bringSubview(toFront: fromView)
        UIView.animate(withDuration: duration, animations: { () -> Void in
            toView.transform = CGAffineTransform.identity
            fromView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        }) { (finished) -> Void in
            transitionContext.completeTransition(true)
        }
    }
}
